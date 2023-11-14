//  _ __ ___   ___ _ __ __ _  ___ ___| |_ __ _| |_
// | '_ ` _ \ / _ | '__/ _` |/ _ / __| __/ _` | __|
// | | | | | |  __| | | (_| |  __\__ | || (_| | |_
// |_| |_| |_|\___|_|  \__, |\___|___/\__\__,_|\__|
//                     |___/
//
// This syncer uses the GitHub API to sync pull requests for the given repository.
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

const prsBuffer = [];
const perPage = params.perPage || 100;

const iterator = octokit.graphql.paginate.iterator(query, {
    owner, repo, perPage
});
  
for await (const response of iterator) {
    const prs = response.repository.pullRequests.nodes
    console.log(`fetched page of GitHub pull requests for: ${owner}/${repo} (${prs.length})`)
    for (const pr of prs) {
        prsBuffer.push(pr)
    }
}

console.log(`fetched ${prsBuffer.length} pull requests for: ${owner}/${repo}`)

const schemaSQL = await Deno.readTextFile("./schema.sql");
const client = new Client(Deno.env.get("MERGESTAT_POSTGRES_URL"));
await client.connect();

const tx = await client.createTransaction("syncs/github-pull-requests");
await tx.begin()

await tx.queryArray(schemaSQL);
await tx.queryArray(`DELETE FROM public.github_pull_requests WHERE repo_id = $1;`, [repoID]);
for await (const pr of prsBuffer) {
    // TODO(patrickdevivo): this is pretty gross, but it works for now.
    // we should refactor this to us a query builder or something.
    await tx.queryArray(`
INSERT INTO public.github_pull_requests (repo_id, additions, author_login, author_association, author_avatar_url, author_name, base_ref_oid, base_ref_name, base_repository_name, body, changed_files, closed, closed_at, comment_count, commit_count, created_at, created_via_email, database_id, deletions, editor_login, head_ref_name, head_ref_oid, head_repository_name, is_draft, label_count, last_edited_at, locked, maintainer_can_modify, mergeable, merged, merged_at, merged_by, number, participant_count, published_at, review_decision, state, title, updated_at, url, labels)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $40, $41)
    `, [repoID, pr.additions, pr.author?.login, pr.authorAssociation, pr.author?.avatarUrl, pr.author?.name, pr.baseRefOid, pr.baseRefName, pr.baseRepository?.name, pr.body, pr.changedFiles, pr.closed, pr.closedAt, pr.comments?.totalCount, pr.commits?.totalCount, pr.createdAt, pr.createdViaEmail, pr.databaseId, pr.deletions, pr.editor?.login, pr.headRefName, pr.headRefOid, pr.headRepository?.name, pr.isDraft, pr.labels?.totalCount, pr.lastEditedAt, pr.locked, pr.maintainerCanModify, pr.mergeable, pr.merged, pr.mergedAt, pr.mergedBy?.login, pr.number, pr.participants?.totalCount, pr.publishedAt, pr.reviewDecision, pr.state, pr.title, pr.updatedAt, pr.url, JSON.stringify(pr.labels.nodes.map((l: {name: string}) => l.name))]);
}

await tx.commit();
await client.end();

console.log(`synced ${prsBuffer.length} pull requests for: ${owner}/${repo} (repo_id: ${repoID})`)

Deno.exit(0)
