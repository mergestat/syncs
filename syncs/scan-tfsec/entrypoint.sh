#!/bin/bash

set -euo pipefail

#                                    _        _
#  _ __ ___   ___ _ __ __ _  ___ ___| |_ __ _| |_
# | '_ ` _ \ / _ | '__/ _` |/ _ / __| __/ _` | __|
# | | | | | |  __| | | (_| |  __\__ | || (_| | |_
# |_| |_| |_|\___|_|  \__, |\___|___/\__\__,_|\__|
#                     |___/
#
# This script runs tfsec on a repository and stores the results in PostgreSQL.
#
# @author: Patrick DeVivo (patrick@mergestat.com)

# apply postgresql schema for the syncer
psql $MERGESTAT_POSTGRES_URL -1 --quiet --file /syncer/schema.sql

tfsec /mergestat/repo -f json --out tfsec.json --soft-fail

# load the data into postgres
jq -rc '[env.MERGESTAT_REPO_ID, . | tostring] | @csv' tfsec.json \
  | psql $MERGESTAT_POSTGRES_URL -1 \
      -c "\set ON_ERROR_STOP on" \
      -c "DELETE FROM public.tfsec_repo_scans WHERE repo_id = '$MERGESTAT_REPO_ID'" \
      -c "\copy public.tfsec_repo_scans (repo_id, results) FROM stdin (FORMAT csv)";
