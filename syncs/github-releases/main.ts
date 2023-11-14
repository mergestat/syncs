//  _ __ ___   ___ _ __ __ _  ___ ___| |_ __ _| |_
// | '_ ` _ \ / _ | '__/ _` |/ _ / __| __/ _` | __|
// | | | | | |  __| | | (_| |  __\__ | || (_| | |_
// |_| |_| |_|\___|_|  \__, |\___|___/\__\__,_|\__|
//                     |___/
//
// This syncer uses the GitHub API to list the releases associated with a repository.
//
// @author: GitStart ()

import { Octokit } from "https://cdn.skypack.dev/@octokit/core?dts";
import { paginateRest } from "https://cdn.skypack.dev/@octokit/plugin-paginate-rest";
import { Client } from "https://deno.land/x/postgres@v0.17.0/mod.ts";

const params = JSON.parse(Deno.env.get("MERGESTAT_PARAMS") || "{}");
const repoID = Deno.env.get("MERGESTAT_REPO_ID")
const repoURL = new URL(Deno.env.get("MERGESTAT_REPO_URL") || "");
const owner = repoURL.pathname.split("/")[1];
const repo = repoURL.pathname.split("/")[2];

const OctokitWithPagination = Octokit.plugin(paginateRest)
const octokit = new OctokitWithPagination({ auth: Deno.env.get("MERGESTAT_AUTH_TOKEN") });
const releasesBuffer = [];
const perPage = params.perPage || 100;

const iterator = await octokit.paginate.iterator("GET /repos/{owner}/{repo}/releases", {
    owner,
    repo,
    per_page: perPage,
})

for await (const { data: releases} of iterator) {
    console.log(`fetched page of releases for: ${owner}/${repo} (${releases.length} releases)`)
    for (const alert of releases) {
        releasesBuffer.push(alert)
    }
}

console.log(`fetched ${releasesBuffer.length} releases for: ${owner}/${repo}`)

const schemaSQL = await Deno.readTextFile("./schema.sql");
const client = new Client(Deno.env.get("MERGESTAT_POSTGRES_URL"));
await client.connect();

const tx = await client.createTransaction("syncs/github-releases");
await tx.begin()

await tx.queryArray(schemaSQL);
await tx.queryArray(`DELETE FROM public.github_releases WHERE repo_id = $1;`, [repoID]);
for await (const release of releasesBuffer) {
    await tx.queryArray(`
INSERT INTO public.github_releases (repo_id, url, assets_url, upload_url, html_url, database_id, author_login, author_url, author_avatar_url, tag_name, target_commitish, name, draft, prerelease, created_at, published_at, assets, tarball_url, zipball_url, body, mentions_count)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21)
    `, [repoID, release.url, release.assets_url, release.upload_url, release.html_url, release.id, release.author.login, release.author.url, release.author.avatar_url, release.tag_name, release.target_commitish, release.name, release.draft, release.prerelease, release.created_at, release.published_at, JSON.stringify(release.assets), release.tarball_url, release.zipball_url, release.body, release.mentions_count]);
}

await tx.commit();
await client.end();

console.log(`synced ${releasesBuffer.length} releases for: ${owner}/${repo} (repo_id: ${repoID})`)

Deno.exit(0)