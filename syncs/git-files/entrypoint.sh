#!/bin/bash

set -euo pipefail

#                                    _        _
#  _ __ ___   ___ _ __ __ _  ___ ___| |_ __ _| |_
# | '_ ` _ \ / _ | '__/ _` |/ _ / __| __/ _` | __|
# | | | | | |  __| | | (_| |  __\__ | || (_| | |_
# |_| |_| |_|\___|_|  \__, |\___|___/\__\__,_|\__|
#                     |___/
#
# This script uses mergestat-lite to list all files in a repo and upload it into PostgreSQL.
#
# @author: Patrick DeVivo (patrick@mergestat.com)

# apply postgresql schema for the syncer
psql $MERGESTAT_POSTGRES_URL -1 --quiet --file /syncer/schema.sql

# the CASE..WHEN clause here nulls the contents of binary files
mergestat "SELECT '$MERGESTAT_REPO_ID', path, executable, CASE (instr(cast(contents AS BLOB), char(0)) < 1) WHEN false THEN NULL ELSE contents END AS contents FROM files" \
    -f csv-noheader \
    -r /mergestat/repo > files.csv

# Assuming input file is UTF-8 and converting to UTF-8 but skipping invalid characters
iconv -f UTF-8 -t UTF-16 -c < files.csv > files_utf16.csv
iconv -f UTF-16 -t UTF-8 -c < files_utf16.csv > files_utf8.csv

# load the data into postgres
cat files_utf8.csv | psql $MERGESTAT_POSTGRES_URL -1 \
  -c "\set ON_ERROR_STOP on" \
  -c "DELETE FROM public.git_files WHERE repo_id = '$MERGESTAT_REPO_ID'" \
  -c "\copy public.git_files (repo_id, path, executable, contents) FROM stdin (FORMAT csv)"
