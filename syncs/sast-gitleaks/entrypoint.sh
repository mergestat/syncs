#!/usr/bin/env sh

set -euo pipefail

#                                    _        _
#  _ __ ___   ___ _ __ __ _  ___ ___| |_ __ _| |_
# | '_ ` _ \ / _ | '__/ _` |/ _ / __| __/ _` | __|
# | | | | | |  __| | | (_| |  __\__ | || (_| | |_
# |_| |_| |_|\___|_|  \__, |\___|___/\__\__,_|\__|
#                     |___/
#
# This script uses gitleaks (https://github.com/gitleaks/gitleaks) tool
# to scan a repository for known secrets.

psql $MERGESTAT_POSTGRES_URL -1 --quiet --file /syncer/schema.sql

gitleaks detect -s /mergestat/repo --no-banner -f json -r _mergestat_gitleaks_scan_results.json

jq -rc '[env.MERGESTAT_REPO_ID, . | tostring] | @csv' _mergestat_gitleaks_scan_results.json \
  | psql $MERGESTAT_POSTGRES_URL -1 --quiet \
      -c "\set ON_ERROR_STOP on" \
      -c "DELETE FROM public.gitleaks_repo_scans WHERE repo_id = '$MERGESTAT_REPO_ID'" \
      -c "\copy public.gitleaks_repo_scans (repo_id, results) FROM stdin (FORMAT csv)";
