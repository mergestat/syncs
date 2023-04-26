// _ __ ___   ___ _ __ __ _  ___ ___| |_ __ _| |_
// | '_ ` _ \ / _ | '__/ _` |/ _ / __| __/ _` | __|
// | | | | | |  __| | | (_| |  __\__ | || (_| | |_
// |_| |_| |_|\___|_|  \__, |\___|___/\__\__,_|\__|
//                     |___/
//
// @author: Riyaz Ali (riyaz@mergestat.com)

import { Client as PostgresClient } from "https://deno.land/x/postgres@v0.17.0/mod.ts";

const REPO_ID = Deno.env.get("MERGESTAT_REPO_ID")

const cmd = ['osv-scanner', '--format', 'json', '-r', '/mergestat/repo']
const brakeman = Deno.run({ cmd, cwd: '/mergestat/repo', stdin: 'null', stdout: 'piped', stderr: 'piped' });

// wait for scanner to complete
const [_, stdout] = await Promise.all([ brakeman.status(), brakeman.output() ]);

const output = new TextDecoder().decode(stdout);

// connect to the postgresql database server
const client = new PostgresClient(Deno.env.get("MERGESTAT_POSTGRES_URL"));
await client.connect();

const tx = await client.createTransaction("syncs/scan-osv");
await tx.begin();

// apply the database schema
const schema = await Deno.readTextFile("./schema.sql");
await tx.queryArray(schema);

// remove any previous records and insert the new record
await tx.queryArray(`DELETE FROM public.osv_repo_scans WHERE repo_id = $1;`, [ REPO_ID ]);
await tx.queryArray(`INSERT INTO public.osv_repo_scans (repo_id, results) VALUES ($1, $2);`, [ REPO_ID, output ]);

// commit the transaction and close the connection
await tx.commit();
await client.end();

// terminate the process
