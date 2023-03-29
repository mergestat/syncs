#!/bin/bash

set -euo pipefail

#                                    _        _
#  _ __ ___   ___ _ __ __ _  ___ ___| |_ __ _| |_
# | '_ ` _ \ / _ | '__/ _` |/ _ / __| __/ _` | __|
# | | | | | |  __| | | (_| |  __\__ | || (_| | |_
# |_| |_| |_|\___|_|  \__, |\___|___/\__\__,_|\__|
#                     |___/
#
# This syncer uses mergestat-lite to sync git refs for the given repository.
#
# @author: Riyaz Ali (riyaz@mergestat.com)

# apply postgresql schema for the syncer
psql $MERGESTAT_POSTGRES_URL -1 --quiet --file /syncer/schema.sql

# extract data and import into mergestat
mergestat --format json 'SELECT *, COALESCE(COMMIT_FROM_TAG(tag), hash) AS tag_commit_hash FROM refs' \
  | jq -rc '.[] | [env.MERGESTAT_REPO_ID, .full_name, .name, .hash, .remote, .target, .type, .tag_commit_hash] | @csv' \
  | psql $MERGESTAT_POSTGRES_URL -1 --quiet \
      -c "DELETE FROM public.git_refs WHERE repo_id = '$MERGESTAT_REPO_ID'" \
      -c "\copy public.git_refs (repo_id, full_name, name, hash, remote, target, type, tag_commit_hash) FROM stdin (FORMAT csv)";
