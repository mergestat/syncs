//  _ __ ___   ___ _ __ __ _  ___ ___| |_ __ _| |_
// | '_ ` _ \ / _ | '__/ _` |/ _ / __| __/ _` | __|
// | | | | | |  __| | | (_| |  __\__ | || (_| | |_
// |_| |_| |_|\___|_|  \__, |\___|___/\__\__,_|\__|
//                     |___/
//
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
const buffer = []
const perPage = params.perPage || 100;
const state = params.state || "all"

// iterator to fetch PRs for the given repo
const iterator = octokit.paginate.iterator(octokit.rest.pulls.list, {
    owner, repo, state,
    per_page: perPage,
})

// iterate over all fetched PRs and store them in the buffer array
for await (const { data } of iterator) {
    console.log(`fetched page of GitHub pull requests for: ${owner}/${repo} (${data.length})`)
    for (const pr of data) {
        buffer.push(pr)
    }
}

for await (const [i, pr] of buffer.entries()) {
    // fetch the *full* JSON of a PR, which includes stats and other metadata not available in the list API
    const fullPR = await octokit.rest.pulls.get({
        owner, repo, pull_number: pr.number,
    })
    
    buffer[i] = fullPR.data

    // fetch the PR commits
    const commitsIter = octokit.paginate.iterator(octokit.rest.pulls.listCommits, {
        owner, repo, pull_number: pr.number,
        per_page: perPage,
    })

    for await (const { data } of commitsIter) {
        console.log(`fetched page of GitHub pull request commits for: ${owner}/${repo} (${data.length})`)
        buffer[i]._commits = data
    }
}

console.log(`fetched ${buffer.length} pull requests and their commits`)

const client = new Client(Deno.env.get("MERGESTAT_POSTGRES_URL"));
await client.connect();

const tx = await client.createTransaction("syncs/github-prs-and-pr-commits");
await tx.begin()

await tx.queryArray(`DELETE FROM public.github_pull_requests WHERE repo_id = $1;`, [repoID]);
await tx.queryArray(`DELETE FROM public.github_pull_request_commits WHERE repo_id = $1;`, [repoID]);

for await (const pr of buffer) {
    await tx.queryArray(`
INSERT INTO public.github_pull_requests (repo_id, additions, author_login, author_association, author_avatar_url, author_name, base_ref_oid, base_ref_name, base_repository_name, body, changed_files, closed, closed_at, comment_count, commit_count, created_at, created_via_email, database_id, deletions, editor_login, head_ref_name, head_ref_oid, head_repository_name, is_draft, label_count, last_edited_at, locked, maintainer_can_modify, mergeable, merged, merged_at, merged_by, number, participant_count, published_at, review_decision, state, title, updated_at, url, labels)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $40, $41)
    `, [repoID, pr.additions, pr.user?.login, pr.author_association, pr.user?.avatar_url, null, pr.base?.sha, pr.base?.ref, pr.base?.repo?.full_name, pr.body, pr.changed_files, pr.closed === 'closed', pr.closed_at, null, pr.commits?.length, pr.created_at, null, pr.id, pr.deletions, null, pr.head?.ref, pr.head?.sha, pr.head?.repo?.full_name, pr.draft, pr.labels?.length, null, pr.locked, null, null, pr.merged_at !== null, pr.merged_at, null, pr.number, null, null, null, pr.state, pr.title, pr.updated_at, pr.url, JSON.stringify(pr.labels.map((l: {name: string}) => l.name))]);

    for await (const commit of pr._commits) {
        await tx.queryArray(`
INSERT INTO public.github_pull_request_commits (repo_id, pr_number, hash, message, author_name, author_email, author_when, committer_name, committer_email, committer_when, additions, deletions, changed_files, url)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
`, [repoID, pr.number, commit.sha, commit.commit.message, commit.commit.author.name, commit.commit.author.email, commit.commit.author.date, commit.commit.committer.name, commit.commit.committer.email, commit.commit.committer.date, null, null, null, commit.url]);
    }
}

await tx.commit();
await client.end();

console.log(`synced ${buffer.length} pull requests for: ${owner}/${repo} (repo_id: ${repoID})`)

Deno.exit(0)
