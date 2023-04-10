#!/bin/bash

set -euo pipefail

#                                    _        _
#  _ __ ___   ___ _ __ __ _  ___ ___| |_ __ _| |_
# | '_ ` _ \ / _ | '__/ _` |/ _ / __| __/ _` | __|
# | | | | | |  __| | | (_| |  __\__ | || (_| | |_
# |_| |_| |_|\___|_|  \__, |\___|___/\__\__,_|\__|
#                     |___/
#
# This syncer uses mergestat-lite to sync Github Pull Request reviews for the given repository.
#
# @author: Riyaz Ali (riyaz@mergestat.com)

# Get the remote URL of the origin
remote_url=$MERGESTAT_REPO_URL

# Parse the owner and name from the remote URL
regex_https="(https|http):\/\/github.com\/([^\/]+)\/([^\/]+)(\.git)?\/?"
regex_ssh="git@github.com:([^\/]+)\/([^\/]+)(\.git)?\/?"
if [[ $remote_url =~ $regex_https ]]; then
    owner=${BASH_REMATCH[2]}
    name=${BASH_REMATCH[3]}
elif [[ $remote_url =~ $regex_ssh ]]; then
    owner=${BASH_REMATCH[1]}
    name=${BASH_REMATCH[2]}
else
    echo "Error: Unable to parse owner and name from remote URL."
    exit 1
fi

# Store the owner and name in variables
repository_owner=$owner
repository_name=${name%.git}
export repository="$repository_owner/$repository_name"

# apply postgresql schema for the syncer
psql $MERGESTAT_POSTGRES_URL -1 --quiet --file /syncer/schema.sql

export GITHUB_TOKEN=$MERGESTAT_AUTH_TOKEN

# extract data and import into mergestat
mergestat --format json -v "SELECT github_prs.number AS pr_number, github_pr_reviews.* FROM github_prs('$repository'), github_pr_reviews('$repository', github_prs.number) ORDER BY github_pr_reviews.created_at DESC" \
  | jq -rc '.[] | [env.MERGESTAT_REPO_ID, .pr_number, .id, .author_login, .author_url, .author_association, .author_can_push_to_repository, .body, .comment_count, .created_at, .created_via_email, .editor_login, .last_edited_at, .published_at, .state, .submitted_at, .updated_at] | @csv' \
  | psql $MERGESTAT_POSTGRES_URL -1 --quiet \
    -c "\set ON_ERROR_STOP on" \
    -c "DELETE FROM public.github_pull_request_reviews WHERE repo_id = '$MERGESTAT_REPO_ID'" \
    -c "\copy public.github_pull_request_reviews (repo_id, pr_number, id, author_login, author_url, author_association, author_can_push_to_repository, body, comment_count, created_at, created_via_email, editor_login, last_edited_at, published_at, state, submitted_at, updated_at) FROM stdin (FORMAT csv)";
