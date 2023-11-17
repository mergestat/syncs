//  _ __ ___   ___ _ __ __ _  ___ ___| |_ __ _| |_
// | '_ ` _ \ / _ | '__/ _` |/ _ / __| __/ _` | __|
// | | | | | |  __| | | (_| |  __\__ | || (_| | |_
// |_| |_| |_|\___|_|  \__, |\___|___/\__\__,_|\__|
//                     |___/
//
// This syncer uses the GitHub API to sync discussions for the given repository.
//
// @author: Patrick DeVivo (patrick@mergestat.com)

import { Octokit } from "https://esm.sh/v124/octokit@2.0.14";
import { paginateGraphql } from "https://cdn.jsdelivr.net/npm/@octokit/plugin-paginate-graphql@2.0.1/+esm";
import { throttling } from "https://esm.sh/@octokit/plugin-throttling";
import { Client } from "https://deno.land/x/postgres@v0.17.0/mod.ts";

const discussionsQuery = await Deno.readTextFile("./discussions_query.gql");
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

const discussionsBuffer = [];
const perPage = params.perPage || 100;

const iterator = octokit.graphql.paginate.iterator(discussionsQuery, {
    owner, repo, perPage
});
  
for await (const response of iterator) {
    const discussions = response.repository.discussions.nodes
    console.log(`fetched page of GitHub discussions for: ${owner}/${repo} (${discussions.length})`)
    for (const discussion of discussions) {
      discussionsBuffer.push(discussion)
    }
}

console.log(`fetched ${discussionsBuffer.length} discussions for: ${owner}/${repo}`)

const schemaSQL = await Deno.readTextFile("./schema.sql");
const client = new Client(Deno.env.get("MERGESTAT_POSTGRES_URL"));
await client.connect();

const tx = await client.createTransaction("syncs/github-discussions");
await tx.begin()

await tx.queryArray(schemaSQL);
await tx.queryArray(`DELETE FROM public.github_discussions WHERE repo_id = $1;`, [repoID]);
for await (const discussion of discussionsBuffer) {
    await tx.queryArray(`
INSERT INTO public.github_discussions (repo_id, id, active_lock_reason, is_answered, answer_id, answer_chosen_at, answer_chosen_by, author_login, author_association, body_text, category, comment_count, created_at, created_via_email, database_id, editor_login, last_edited_at, locked, number, published_at, reaction_count, title, updated_at, url)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22, $23, $24)
    `, [repoID, discussion.id, discussion.activeLockReason, discussion.isAnswered, discussion.answer?.id, discussion.answerChosenAt, discussion.answerChosenBy?.login, discussion.author?.login, discussion.authorAssociation, discussion.bodyText, discussion.category?.name, discussion.comments?.totalCount, discussion.createdAt, discussion.createdViaEmail, discussion.databaseId, discussion.editor?.login, discussion.lastEditedAt, discussion.locked, discussion.number, discussion.publishedAt, discussion.reactions?.totalCount, discussion.title, discussion.updatedAt, discussion.url]);
}

await tx.commit();

await client.end();

console.log(`synced ${discussionsBuffer.length} discussions for: ${owner}/${repo} (repo_id: ${repoID})`)

Deno.exit(0)
