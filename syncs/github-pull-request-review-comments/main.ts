//  _ __ ___   ___ _ __ __ _  ___ ___| |_ __ _| |_
// | '_ ` _ \ / _ | '__/ _` |/ _ / __| __/ _` | __|
// | | | | | |  __| | | (_| |  __\__ | || (_| | |_
// |_| |_| |_|\___|_|  \__, |\___|___/\__\__,_|\__|
//                     |___/
//
// This syncer uses the GitHub API to sync PR review comments for the given repository.
//
// @author: Patrick DeVivo (patrick@mergestat.com)

import { Octokit } from "https://esm.sh/v124/octokit@2.0.14";
import { throttling } from "https://esm.sh/@octokit/plugin-throttling";
import { Client } from "https://deno.land/x/postgres@v0.17.0/mod.ts";

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

const iterator = octokit.paginate.iterator(`GET /repos/${owner}/${repo}/pulls/comments`, {
    headers: {
        'X-GitHub-Api-Version': '2022-11-28'
    },
    owner, repo
});
  
for await (const { data: comments } of iterator) {
    console.log(`fetched page of PR review comments for: ${owner}/${repo} (${comments.length} review comments)`)
    for (const alert of comments) {
        commentsBuffer.push(alert)
    }
}

console.log(`fetched ${commentsBuffer.length} PR review comments for: ${owner}/${repo}`)

const schemaSQL = await Deno.readTextFile("./schema.sql");
const client = new Client(Deno.env.get("MERGESTAT_POSTGRES_URL"));
await client.connect();

const tx = await client.createTransaction("syncs/github-pr-review-comments");
await tx.begin()

await tx.queryArray(schemaSQL);
await tx.queryArray(`DELETE FROM public.github_pr_review_comments WHERE repo_id = $1;`, [repoID]);
for await (const comment of commentsBuffer) {
    await tx.queryArray(`
INSERT INTO public.github_pr_review_comments (repo_id, url, pull_request_review_id, pull_request_number, id, diff_hunk, path, commit_id, original_commit_id, user_login, user_id, user_avatar_url, user_url, created_at, updated_at, author_association, body, reactions, start_line, original_start_line, start_side, line, original_line, side, original_position, position, subject_type)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22, $23, $24, $25, $26, $27)
    `, [
        repoID,
        comment.url,
        comment.pull_request_review_id,
        comment.pull_request_url.split("/").pop(),
        comment.id,
        comment.diff_hunk,
        comment.path,
        comment.commit_id,
        comment.original_commit_id,
        comment.user?.login,
        comment.user?.id,
        comment.user?.avatar_url,
        comment.user?.url,
        comment.created_at,
        comment.updated_at,
        comment.author_association,
        comment.body,
        JSON.stringify(comment.reactions),
        comment.start_line,
        comment.original_start_line,
        comment.start_side,
        comment.line,
        comment.original_line,
        comment.side,
        comment.original_position,
        comment.position,
        comment.subject_type
    ]);
}
await tx.commit();

await client.end();

console.log(`synced ${commentsBuffer.length} PR review comments for: ${owner}/${repo} (repo_id: ${repoID})`)

Deno.exit(0)
