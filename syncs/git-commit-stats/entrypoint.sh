#!/bin/bash

set -euo pipefail

#                                    _        _
#  _ __ ___   ___ _ __ __ _  ___ ___| |_ __ _| |_
# | '_ ` _ \ / _ | '__/ _` |/ _ / __| __/ _` | __|
# | | | | | |  __| | | (_| |  __\__ | || (_| | |_
# |_| |_| |_|\___|_|  \__, |\___|___/\__\__,_|\__|
#                     |___/
#
# This script uses mergestat-lite to retrieve commit stats and store them in PostgreSQL.
#
# @author: Patrick DeVivo (patrick@mergestat.com)

# apply postgresql schema for the syncer
psql $MERGESTAT_POSTGRES_URL -1 --quiet --file /syncer/schema.sql

mergestat "SELECT '$MERGESTAT_REPO_ID', hash, file_path, additions, deletions, old_file_mode, new_file_mode FROM commits, stats('', commits.hash)" \
     -f csv-noheader \
     -r /mergestat/repo > commit-stats.csv


# load the data into postgres
cat commit-stats.csv | psql $MERGESTAT_POSTGRES_URL --quiet <<EOF
  BEGIN;
    DELETE FROM public.git_commit_stats WHERE repo_id = '$MERGESTAT_REPO_ID';
    COPY public.git_commit_stats (repo_id, commit_hash, file_path, additions, deletions, old_file_mode, new_file_mode) FROM stdin (FORMAT csv);
  COMMIT;
EOF
