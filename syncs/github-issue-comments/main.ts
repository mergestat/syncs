//  _ __ ___   ___ _ __ __ _  ___ ___| |_ __ _| |_
// | '_ ` _ \ / _ | '__/ _` |/ _ / __| __/ _` | __|
// | | | | | |  __| | | (_| |  __\__ | || (_| | |_
// |_| |_| |_|\___|_|  \__, |\___|___/\__\__,_|\__|
//                     |___/
//
// This syncer uses the GitHub API to sync issue comments for the given repository.
//
// @author: Patrick DeVivo (patrick@mergestat.com)

import { Octokit } from "https://esm.sh/v124/octokit@2.0.14";
import { throttling } from "https://esm.sh/@octokit/plugin-throttling";
import { Client } from "https://deno.land/x/postgres@v0.17.0/mod.ts";

const params = JSON.parse(Deno.env.get("MERGESTAT_PARAMS") || "{}");
const repoID = Deno.env.get("MERGESTAT_REPO_ID")
const repoURL = new URL(Deno.env.get("MERGESTAT_REPO_URL") || "");
const owner = repoURL.pathname.split("/")[1];
const repo = repoURL.pathname.split("/")[2];

const OctokitWithThrottling = Octokit.plugin(throttling);
const octokit = new OctokitWithThrottling({
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
const commentsBuffer = [];
const perPage = params.perPage || 100;

const iterator = octokit.paginate.iterator(`GET /repos/${owner}/${repo}/issues/comments`, {
    headers: {
        'X-GitHub-Api-Version': '2022-11-28'
    },
    owner, repo,
    per_page: perPage,
});
  
for await (const { data: comments } of iterator) {
    console.log(`fetched page of issue comments for: ${owner}/${repo} (${comments.length} comments)`)
    for (const alert of comments) {
        commentsBuffer.push(alert)
    }
}

console.log(`fetched ${commentsBuffer.length} issue comments for: ${owner}/${repo}`)

const schemaSQL = await Deno.readTextFile("./schema.sql");
const client = new Client(Deno.env.get("MERGESTAT_POSTGRES_URL"));
await client.connect();

const tx = await client.createTransaction("syncs/github-issue-comments");
await tx.begin()

await tx.queryArray(schemaSQL);
await tx.queryArray(`DELETE FROM public.github_issue_comments WHERE repo_id = $1;`, [repoID]);
for await (const comment of commentsBuffer) {
    await tx.queryArray(`
INSERT INTO public.github_issue_comments (repo_id, id, issue_number, url, user_login, user_id, user_type, user_avatar_url, user_url, created_at, updated_at, author_association, body, reactions)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
    `, [repoID, comment.id, comment.issue_url.split("/").pop(), comment.url, comment.user?.login, comment.user?.id, comment.user?.type, comment.user?.avatar_url, comment.user?.url, comment.created_at, comment.updated_at, comment.author_association, comment.body, JSON.stringify(comment.reactions)]);
}
await tx.commit();

await client.end();

console.log(`synced ${commentsBuffer.length} issue comments for: ${owner}/${repo} (repo_id: ${repoID})`)

Deno.exit(0)
