#!/usr/bin/env sh

#                                    _        _
#  _ __ ___   ___ _ __ __ _  ___ ___| |_ __ _| |_
# | '_ ` _ \ / _ | '__/ _` |/ _ / __| __/ _` | __|
# | | | | | |  __| | | (_| |  __\__ | || (_| | |_
# |_| |_| |_|\___|_|  \__, |\___|___/\__\__,_|\__|
#                     |___/
#
# This script uses git blame to list blame data for all files in the repository.
#
# @author: Riyaz Ali (riyaz@mergestat.com)

set -e

# apply postgresql schema for the syncer
psql $MERGESTAT_POSTGRES_URL -1 --quiet --file /syncer/schema.sql

# run the sync implementation
git-blame-to-csv /mergestat/repo blame.csv

# load the data into postgres
cat blame.csv | psql $MERGESTAT_POSTGRES_URL -1 \
  -c "\set ON_ERROR_STOP on" \
  -c "DELETE FROM public.git_blame WHERE repo_id = '$MERGESTAT_REPO_ID'" \
  -c "\copy public.git_blame (repo_id, author_email, author_name, author_when, commit_hash, line_no, line, path) FROM stdin (FORMAT csv)"
