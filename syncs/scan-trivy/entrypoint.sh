#!/usr/bin/env sh

set -euo pipefail

#                                    _        _
#  _ __ ___   ___ _ __ __ _  ___ ___| |_ __ _| |_
# | '_ ` _ \ / _ | '__/ _` |/ _ / __| __/ _` | __|
# | | | | | |  __| | | (_| |  __\__ | || (_| | |_
# |_| |_| |_|\___|_|  \__, |\___|___/\__\__,_|\__|
#                     |___/
#
# This script uses trivy (https://github.com/aquasecurity/trivy)
# to scan a repository for CVEs.

psql $MERGESTAT_POSTGRES_URL -1 --quiet --file /syncer/schema.sql

export GITHUB_TOKEN=$MERGESTAT_AUTH_TOKEN

trivy repository $MERGESTAT_REPO_URL -q -f json --timeout 30m > _mergestat_trivy_scan_results.json

jq -rc '[env.MERGESTAT_REPO_ID, . | tostring] | @csv' _mergestat_trivy_scan_results.json \
  | psql $MERGESTAT_POSTGRES_URL -1 --quiet \
      -c "\set ON_ERROR_STOP on" \
      -c "DELETE FROM public.trivy_repo_scans WHERE repo_id = '$MERGESTAT_REPO_ID'" \
      -c "\copy public.trivy_repo_scans (repo_id, results) FROM stdin (FORMAT csv)";
