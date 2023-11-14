//  _ __ ___   ___ _ __ __ _  ___ ___| |_ __ _| |_
// | '_ ` _ \ / _ | '__/ _` |/ _ / __| __/ _` | __|
// | | | | | |  __| | | (_| |  __\__ | || (_| | |_
// |_| |_| |_|\___|_|  \__, |\___|___/\__\__,_|\__|
//                     |___/
//
// This syncer uses the GitHub API to sync info about a given repo.
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

const { data: repoInfo } = await octokit.rest.repos.get({
    owner,
    repo,
});

const { data: latestRelease } = await octokit.rest.repos.getLatestRelease({
    owner,
    repo,
}).catch((e: any) => {
    // if a 404 is thrown, it means there is no release
    // so we return null to handle it gracefully
    if (e.status === 404) {
        return { data: null }
    }
});

const perPage = params.perPage || 100;

const releasesIter = octokit.paginate.iterator(octokit.rest.repos.listReleases, {
    owner, repo,
    per_page: perPage,
})

let totalReleases = 0;
for await (const { data: releases } of releasesIter) {
    for (const release of releases) {
        totalReleases += 1;
    }
}

const schemaSQL = await Deno.readTextFile("./schema.sql");
const client = new Client(Deno.env.get("MERGESTAT_POSTGRES_URL"));
await client.connect();

const tx = await client.createTransaction("syncs/github-repo-info");
await tx.begin()

await tx.queryArray(schemaSQL);
await tx.queryArray(`DELETE FROM public.github_repo_info WHERE repo_id = $1;`, [repoID]);
await tx.queryArray(`
INSERT INTO public.github_repo_info (repo_id, owner, name, created_at, default_branch_name, description, size, fork_count, homepage_url, is_archived, is_disabled, is_private, total_issues_count, latest_release_author, latest_release_created_at, latest_release_name, latest_release_published_at, license_key, license_name, primary_language, pushed_at, releases_count, stargazers_count, updated_at, watchers_count, advanced_security, secret_scanning, secret_scanning_push_protection, mirror_url)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22, $23, $24, $25, $26, $27, $28, $29)
    `, [repoID, repoInfo.owner.login, repoInfo.name, repoInfo.created_at, repoInfo.default_branch, repoInfo.description, repoInfo.size, repoInfo.forks_count, repoInfo.homepage, repoInfo.archived, repoInfo.disabled, repoInfo.private, repoInfo.open_issues_count, latestRelease?.author?.login, latestRelease?.created_at, latestRelease?.name, latestRelease?.published_at, repoInfo.license?.key, repoInfo.license?.name, repoInfo.language, repoInfo.pushed_at, totalReleases, repoInfo.stargazers_count, repoInfo.updated_at, repoInfo.watchers_count, repoInfo.security_and_analysis?.advanced_security?.status, repoInfo.security_and_analysis?.secret_scanning?.status, repoInfo.security_and_analysis?.secret_scanning_push_protection?.status, repoInfo.mirror_url]);

await tx.commit();
await client.end();

Deno.exit(0)
