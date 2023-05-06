#!/bin/bash

set -euo pipefail

#                                    _        _
#  _ __ ___   ___ _ __ __ _  ___ ___| |_ __ _| |_
# | '_ ` _ \ / _ | '__/ _` |/ _ / __| __/ _` | __|
# | | | | | |  __| | | (_| |  __\__ | || (_| | |_
# |_| |_| |_|\___|_|  \__, |\___|___/\__\__,_|\__|
#                     |___/
#
# This script uses mergestat-lite to retrieve data for the explore experience.
#
# @author: Patrick DeVivo (patrick@mergestat.com)

# apply postgresql schema for the syncer
psql $MERGESTAT_POSTGRES_URL -1 --quiet --file /syncer/schema.sql


# handle git_commits
mergestat "SELECT '$MERGESTAT_REPO_ID', hash, message, author_name, author_email, author_when, committer_name, committer_email, committer_when, parents FROM commits" \
     -f csv-noheader \
     -r /mergestat/repo > commits.csv


# load the data into postgres
cat commits.csv | psql $MERGESTAT_POSTGRES_URL -1 \
  -c "\set ON_ERROR_STOP on" \
  -c "DELETE FROM public.git_commits WHERE repo_id = '$MERGESTAT_REPO_ID'" \
  -c "\copy public.git_commits (repo_id, hash, message, author_name, author_email, author_when, committer_name, committer_email, committer_when, parents) FROM stdin (FORMAT csv)"


rm commits.csv

# handle git_commit_stats
mergestat "SELECT '$MERGESTAT_REPO_ID', hash, file_path, additions, deletions, old_file_mode, new_file_mode FROM commits, stats('', commits.hash)" \
     -f csv-noheader \
     -r /mergestat/repo > commit-stats.csv


# load the data into postgres
cat commit-stats.csv | psql $MERGESTAT_POSTGRES_URL -1 \
  -c "\set ON_ERROR_STOP on" \
  -c "DELETE FROM public.git_commit_stats WHERE repo_id = '$MERGESTAT_REPO_ID'" \
  -c "\copy public.git_commit_stats (repo_id, commit_hash, file_path, additions, deletions, old_file_mode, new_file_mode) FROM stdin (FORMAT csv)"

rm commit-stats.csv

# handle git_files
# the CASE..WHEN clause here nulls the contents of binary files
mergestat "SELECT '$MERGESTAT_REPO_ID', path, executable, CASE (instr(cast(contents AS BLOB), char(0)) < 1) WHEN false THEN NULL ELSE contents END AS contents FROM files" \
    -f csv-noheader \
    -r /mergestat/repo > files.csv

# Assuming input file is UTF-8 and converting to UTF-8 but skipping invalid characters
iconv -f UTF-8 -t UTF-8 -c < files.csv > files_utf8.csv

# load the data into postgres
cat files_utf8.csv | psql $MERGESTAT_POSTGRES_URL -1 \
  -c "\set ON_ERROR_STOP on" \
  -c "DELETE FROM public.git_files WHERE repo_id = '$MERGESTAT_REPO_ID'" \
  -c "\copy public.git_files (repo_id, path, executable, contents) FROM stdin (FORMAT csv)"

rm files.csv files_utf8.csv

# populate _mergestat_explore_repo_metadata
psql $MERGESTAT_POSTGRES_URL -1 \
  -c "\set ON_ERROR_STOP on" \
  -c "DELETE FROM public._mergestat_explore_repo_metadata WHERE repo_id = '$MERGESTAT_REPO_ID'" \
  -c "INSERT INTO _mergestat_explore_repo_metadata (repo_id, last_commit_hash) SELECT DISTINCT ON (repo_id) repo_id, hash AS last_commit_hash FROM git_commits WHERE repo_id = '$MERGESTAT_REPO_ID' AND git_commits.parents < 2 ORDER BY repo_id, author_when DESC"


# populate _mergestat_explore_file_metadata
psql $MERGESTAT_POSTGRES_URL -1 \
  -c "\set ON_ERROR_STOP on" \
  -c "DELETE FROM public._mergestat_explore_file_metadata WHERE repo_id = '$MERGESTAT_REPO_ID'" \
  -c "INSERT INTO _mergestat_explore_file_metadata (repo_id, path, last_commit_hash) SELECT DISTINCT ON (git_commits.repo_id, file_path) git_commits.repo_id, file_path AS path, hash AS last_commit_hash FROM git_commit_stats JOIN git_commits ON git_commits.hash = git_commit_stats.commit_hash WHERE git_commits.repo_id = '$MERGESTAT_REPO_ID' AND git_commits.parents < 2 ORDER BY repo_id, file_path, author_when DESC;"
