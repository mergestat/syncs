#!/usr/bin/env sh

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

# @TODO: manage public.git_commits schema

git log --pretty=fuller --shortstat \
    | jc --git-log-s -u \
    | jq -rc '. + {"parents": (try (.merge | split(" ") | length) catch 0) }' \
    | jq -rc '[env.MERGESTAT_REPO_ID, .commit, .message, .author, .author_email, .date, .commit_by, .commit_by_email, .commit_by_date, .parents] | @csv' \
    | psql $MERGESTAT_POSTGRES_URL -1 \
        -c "DELETE FROM git_commits WHERE repo_id = '$MERGESTAT_REPO_ID'" \
        -c "\copy git_commits (repo_id, hash, message, author_name, author_email, author_when, committer_name, committer_email, committer_when, parents) FROM stdin (FORMAT csv)";
