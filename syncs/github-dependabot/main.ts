//  _ __ ___   ___ _ __ __ _  ___ ___| |_ __ _| |_
// | '_ ` _ \ / _ | '__/ _` |/ _ / __| __/ _` | __|
// | | | | | |  __| | | (_| |  __\__ | || (_| | |_
// |_| |_| |_|\___|_|  \__, |\___|___/\__\__,_|\__|
//                     |___/
//
// This syncer uses the GitHub API to sync Dependabot alerts for the given repository.
//
// @author: Patrick DeVivo (patrick@mergestat.com)

import { Octokit } from "https://esm.sh/v124/octokit@2.0.14";
import { Client } from "https://deno.land/x/postgres@v0.17.0/mod.ts";

const repoID = Deno.env.get("MERGESTAT_REPO_ID")
const repoURL = new URL(Deno.env.get("MERGESTAT_REPO_URL") || "");
const owner = repoURL.pathname.split("/")[1];
const repo = repoURL.pathname.split("/")[2];

const octokit = new Octokit({ auth: Deno.env.get("MERGESTAT_AUTH_TOKEN") });
const alertsBuffer = [];

const iterator = octokit.paginate.iterator(`GET /repos/${owner}/${repo}/dependabot/alerts`, {
    headers: {
        'X-GitHub-Api-Version': '2022-11-28'
    },
    owner, repo
});
  
for await (const { data: alerts } of iterator) {
    console.log(`fetched page of dependabot alerts for: ${owner}/${repo} (${alerts.length} alerts)`)
    for (const alert of alerts) {
        alertsBuffer.push(alert)
    }
}

console.log(`fetched ${alertsBuffer.length} dependabot alerts for: ${owner}/${repo}`)

const schemaSQL = await Deno.readTextFile("./schema.sql");
const client = new Client(Deno.env.get("MERGESTAT_POSTGRES_URL"));
await client.connect();

const tx = await client.createTransaction("syncs/github-dependabot");
await tx.begin()

await tx.queryArray(schemaSQL);
await tx.queryArray(`DELETE FROM public.github_repo_dependabot_alert_results WHERE repo_id = $1;`, [repoID]);
await tx.queryArray(`INSERT INTO public.github_repo_dependabot_alert_results (repo_id, dependabot_alerts) VALUES ($1, $2)`, [repoID, JSON.stringify(alertsBuffer)]);
await tx.commit();

await client.end();

console.log(`synced ${alertsBuffer.length} dependabot alerts for: ${owner}/${repo} (repo_id: ${repoID})`)

Deno.exit(0)
