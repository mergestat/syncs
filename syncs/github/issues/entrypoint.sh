#!/usr/bin/env sh

#                                    _        _
#  _ __ ___   ___ _ __ __ _  ___ ___| |_ __ _| |_
# | '_ ` _ \ / _ | '__/ _` |/ _ / __| __/ _` | __|
# | | | | | |  __| | | (_| |  __\__ | || (_| | |_
# |_| |_| |_|\___|_|  \__, |\___|___/\__\__,_|\__|
#                     |___/
#
# This script uses github cli to list all issues from the corresponding Github repository.
#
# @author: Riyaz Ali (riyaz@mergestat.com)

GITHUB_TOKEN=$MERGESTAT_AUTH_TOKEN gh api graphql --paginate -F owner='{owner}' -F repo='{repo}' -q '.data.repository.issues.nodes' -F query=@/query.gql \
  | jq -r '.[] | . + ({ "all_labels": [.labels.nodes[].name] | tostring })' \
  | jq -rc '[env.MERGESTAT_REPO_ID, .author.login, .body, .closed, .closedAt, .comments.totalCount, .createdAt, .createdViaEmail, .databaseId, .editor.login, .includesCreatedEdit, .labels.totalCount, .lastEditedAt, .locked, .milestone.totalCount, .number, .participants.totalCount, .publishedAt, .reactions.totalCount, .state, .title, .updatedAt, .url, .all_labels] | @csv' \
  | psql $MERGESTAT_POSTGRES_URL -1 \
    -c "DELETE FROM public.github_issues WHERE repo_id = '$MERGESTAT_REPO_ID'" \
    -c "\copy public.github_issues (repo_id, author_login, body, closed, closed_at, comment_count, created_at, created_via_email, database_id, editor_login, includes_created_edit, label_count, last_edited_at, locked, milestone_count, number, participant_count, published_at, reaction_count, state, title, updated_at, url, labels) FROM stdin (FORMAT csv)";

