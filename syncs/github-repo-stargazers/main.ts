//  _ __ ___   ___ _ __ __ _  ___ ___| |_ __ _| |_
// | '_ ` _ \ / _ | '__/ _` |/ _ / __| __/ _` | __|
// | | | | | |  __| | | (_| |  __\__ | || (_| | |_
// |_| |_| |_|\___|_|  \__, |\___|___/\__\__,_|\__|
//                     |___/
//
// This syncer uses the GitHub API to sync stargazers for the given repository.
//
// @author: Patrick DeVivo (patrick@mergestat.com)

import { Octokit } from "https://esm.sh/v124/octokit@2.0.14";
import { paginateGraphql } from "https://cdn.jsdelivr.net/npm/@octokit/plugin-paginate-graphql@2.0.1/+esm";
import { throttling } from "https://esm.sh/@octokit/plugin-throttling";
import { Client } from "https://deno.land/x/postgres@v0.17.0/mod.ts";

const query = await Deno.readTextFile("./query.gql");
const params = JSON.parse(Deno.env.get("MERGESTAT_PARAMS") || "{}");
const repoID = Deno.env.get("MERGESTAT_REPO_ID")
const repoURL = new URL(Deno.env.get("MERGESTAT_REPO_URL") || "");
const owner = repoURL.pathname.split("/")[1];
const repo = repoURL.pathname.split("/")[2];

const OctokitWithGrapQLPagination = Octokit.plugin(paginateGraphql, throttling);
const octokit = new OctokitWithGrapQLPagination({
    auth: Deno.env.get("MERGESTAT_AUTH_TOKEN"),
    throttle: {
        onRateLimit: (retryAfter, options, octokit, retryCount) => {
          octokit.log.warn(
            `Request quota exhausted for request ${options.method} ${options.url}`
          );
    
          if (retryCount < 1) {
            // only retries once
            octokit.log.info(`Retrying after ${retryAfter} seconds!`);
            return true;
          }
        },
        onSecondaryRateLimit: (retryAfter, options, octokit) => {
          // does not retry, only logs a warning
          octokit.log.warn(
            `SecondaryRateLimit detected for request ${options.method} ${options.url}`
          );
        },
      },
});

const buffer = [];
const perPage = params.perPage || 100;

const iterator = octokit.graphql.paginate.iterator(query, {
    owner, repo, perPage
});
  
for await (const response of iterator) {
    const stars = response.repository.stargazers.edges
    console.log(`fetched page of GitHub stargazers for: ${owner}/${repo} (${stars.length})`)
    for (const star of stars) {
        buffer.push(star)
    }
}

console.log(`fetched ${buffer.length} stargazers for: ${owner}/${repo}`)

const schemaSQL = await Deno.readTextFile("./schema.sql");
const client = new Client(Deno.env.get("MERGESTAT_POSTGRES_URL"));
await client.connect();

const tx = await client.createTransaction("syncs/github-repo-stargazers");
await tx.begin()

await tx.queryArray(schemaSQL);
await tx.queryArray(`DELETE FROM public.github_stargazers WHERE repo_id = $1;`, [repoID]);
for await (const star of buffer) {
    // TODO(patrickdevivo): this is pretty gross, but it works for now.
    // we should refactor this to us a query builder or something.
    await tx.queryArray(`
INSERT INTO public.github_stargazers (repo_id, login, email, name, bio, company, avatar_url, created_at, updated_at, twitter, website, location, starred_at)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
    `, [repoID, star.node.login, star.node.email, star.node.name, star.node.bio, star.node.company, star.node.avatarUrl, star.node.createdAt, star.node.updatedAt, star.node.twitterUsername, star.node.websiteUrl, star.node.location, star.starredAt]);
}

await tx.commit();
await client.end();

console.log(`synced ${buffer.length} stargazers for: ${owner}/${repo} (repo_id: ${repoID})`)

Deno.exit(0)
