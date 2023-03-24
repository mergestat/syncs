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

# apply postgresql schema for the syncer
psql $MERGESTAT_POSTGRES_URL -1 --quiet --file /syncer/schema.sql

# using git ls-tree and jq find all blobs to iterate over
git ls-tree --format='{"type": "%(objecttype)", "path": "%(path)"}' -r HEAD | jq -r 'select(.type == "blob") | .path' > blobs.txt;

(while read -r path; do python /syncer/blame.py $path; done < blobs.txt) \
  | jq -rc '[env.MERGESTAT_REPO_ID, .email, .name, .time, .hash, .line_number, .line, .path] | @csv' \
  | psql $MERGESTAT_POSTGRES_URL -1 \
      -c "DELETE FROM public.git_blame WHERE repo_id = '$MERGESTAT_REPO_ID'" \
      -c "\copy public.git_blame (repo_id, author_email, author_name, author_when, commit_hash, line_no, line, path) FROM stdin (FORMAT csv)";
