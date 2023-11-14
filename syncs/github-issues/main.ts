//  _ __ ___   ___ _ __ __ _  ___ ___| |_ __ _| |_
// | '_ ` _ \ / _ | '__/ _` |/ _ / __| __/ _` | __|
// | | | | | |  __| | | (_| |  __\__ | || (_| | |_
// |_| |_| |_|\___|_|  \__, |\___|___/\__\__,_|\__|
//                     |___/
//
// This syncer uses the GitHub API to sync issues for the given repository.
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

const issuesBuffer = [];
const perPage = params.perPage || 100;

const iterator = octokit.graphql.paginate.iterator(query, {
    owner, repo, perPage
});
  
for await (const response of iterator) {
    const issues = response.repository.issues.nodes
    console.log(`fetched page of GitHub issues for: ${owner}/${repo} (${issues.length})`)
    for (const issue of issues) {
        issuesBuffer.push(issue)
    }
}

console.log(`fetched ${issuesBuffer.length} issues for: ${owner}/${repo}`)

const schemaSQL = await Deno.readTextFile("./schema.sql");
const client = new Client(Deno.env.get("MERGESTAT_POSTGRES_URL"));
await client.connect();

const tx = await client.createTransaction("syncs/github-issues");
await tx.begin()

await tx.queryArray(schemaSQL);
await tx.queryArray(`DELETE FROM public.github_issues WHERE repo_id = $1;`, [repoID]);
for await (const issue of issuesBuffer) {
    await tx.queryArray(`
INSERT INTO public.github_issues (repo_id, author_login, body, closed, closed_at, comment_count, created_at, created_via_email, database_id, editor_login, includes_created_edit, label_count, last_edited_at, locked, milestone_count, number, participant_count, published_at, reaction_count, state, title, updated_at, url, labels)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22, $23, $24)
    `, [repoID, issue.author?.login, issue.body, issue.closed, issue.closedAt, issue.comments?.totalCount, issue.createdAt, issue.createdViaEmail, issue.databaseId, issue.editor?.login, issue.includesCreatedEdit, issue.labels?.totalCount, issue.lastEditedAt, issue.locked, issue.milestones?.totalCount, issue.number, issue.participants.totalCount, issue.publishedAt, issue.reactions.totalCount, issue.state, issue.title, issue.updatedAt, issue.url, JSON.stringify(issue.labels.nodes.map((l: {name: string}) => l.name))]);
}

await tx.commit();

await client.end();

console.log(`synced ${issuesBuffer.length} issues for: ${owner}/${repo} (repo_id: ${repoID})`)

Deno.exit(0)
