#!/usr/bin/env sh

set -euxo pipefail

#                                    _        _
#  _ __ ___   ___ _ __ __ _  ___ ___| |_ __ _| |_
# | '_ ` _ \ / _ | '__/ _` |/ _ / __| __/ _` | __|
# | | | | | |  __| | | (_| |  __\__ | || (_| | |_
# |_| |_| |_|\___|_|  \__, |\___|___/\__\__,_|\__|
#                     |___/
#
# This script uses git log to list all commits in the default checked out branch.
# It then parses the output of the git-log command using json-cli to convert it into json,
# and process it using jq to convert it to csv to pass to psql.
#
# @author: Riyaz Ali (riyaz@mergestat.com)

# apply postgresql schema for the syncer
psql $MERGESTAT_POSTGRES_URL -1 --quiet --file /syncer/schema.sql


mergestat "SELECT '$MERGESTAT_REPO_ID', hash, message, author_name, author_email, author_when, committer_name, committer_email, committer_when, parents FROM commits" \
     -f csv-noheader \
     -r /mergestat/repo > commits.csv


# load the data into postgres
cat commits.csv | psql $MERGESTAT_POSTGRES_URL -1 \
  -c "\set ON_ERROR_STOP on" \
  -c "DELETE FROM public.git_commits WHERE repo_id = '$MERGESTAT_REPO_ID'" \
  -c "\copy public.git_commits (repo_id, hash, message, author_name, author_email, author_when, committer_name, committer_email, committer_when, parents) FROM stdin (FORMAT csv)"
