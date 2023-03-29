#!/bin/bash

set -euo pipefail

#                                    _        _
#  _ __ ___   ___ _ __ __ _  ___ ___| |_ __ _| |_
# | '_ ` _ \ / _ | '__/ _` |/ _ / __| __/ _` | __|
# | | | | | |  __| | | (_| |  __\__ | || (_| | |_
# |_| |_| |_|\___|_|  \__, |\___|___/\__\__,_|\__|
#                     |___/
#
# This script uses github cli to list all pull requests from the corresponding Github repository.
#
# @author: Riyaz Ali (riyaz@mergestat.com)

# apply postgresql schema for the syncer
psql $MERGESTAT_POSTGRES_URL -1 --quiet --file /syncer/schema.sql

export GITHUB_TOKEN=$MERGESTAT_AUTH_TOKEN

# extract data and import into mergestat
gh api graphql --paginate -F owner='{owner}' -F repo='{repo}' -q '.data.repository.pullRequests.nodes' -F query=@/syncer/query.gql \
  | jq -r '.[] | . + ({ "all_labels": [.labels.nodes[].name] | tostring })' \
  | jq -rc '[env.MERGESTAT_REPO_ID, .additions, .author.login, .authorAssociation, .author.avatarUrl, .author.name, .baseRefOid, .baseRefName, .baseRepository.name, .body, .changedFiles, .closed, .closedAt .comments.totalCount, .commits.totalCount, .createdAt, .createdViaEmail, .databaseId, deletions, .editor.login, .headRefname, .headRefOid, .headRepository.name, .isDraft, .labels.totalCount, .lastEditedAt, .locked, .maintainerCanModify, .mergeable, .merged, .mergedAt, .mergedBy.login, .number, .participants.totalCount, .publishedAt, .reviewDecision, .state, .title, .updatedAt, .url, .all_labels]' \
  | psql $MERGESTAT_POSTGRES_URL -1 \
    -c "DELETE FROM public.github_pull_requests WHERE repo_id = '$MERGESTAT_REPO_ID'" \
    -c "\copy public.github_pull_requests (repo_id, additions, author_login, author_association, author_avatar_url, author_name, base_ref_oid, base_ref_name, base_repository_name, body, changed_files, closed, closed_at, comment_count, commit_count, created_at, created_via_email, database_id, deletions, editor_login, head_ref_name, head_ref_oid, head_repository_name, is_draft, label_count, last_edited_at, locked, maintainer_can_modify, mergeable, merged, merged_at, merged_by, number, participant_count, published_at, review_decision, state, title, updated_at, url, labels) FROM stdin (FORMAT csv)";