#!/usr/bin/env sh

set -euo pipefail

#                                    _        _
#  _ __ ___   ___ _ __ __ _  ___ ___| |_ __ _| |_
# | '_ ` _ \ / _ | '__/ _` |/ _ / __| __/ _` | __|
# | | | | | |  __| | | (_| |  __\__ | || (_| | |_
# |_| |_| |_|\___|_|  \__, |\___|___/\__\__,_|\__|
#                     |___/
#
# This script uses gosec (https://github.com/securego/gosec) to check
# Golang source code for any know vulnerability or anti-patterns.

#
# @author: Riyaz Ali (riyaz@mergestat.com)

(cd /mergestat/repo && /usr/local/bin/gosec -no-fail -fmt json ./...) \
    | jq -rc '.Issues | map(. + { "file": .file | sub("/src"; .file) }) | [env.MERGESTAT_REPO_ID, (. | tostring)] | @csv' \
    | psql $MERGESTAT_POSTGRES_URL -1 \
        -c "\set ON_ERROR_STOP on" \
        -c "DELETE FROM public.gosec_repo_scans WHERE repo_id = '$MERGESTAT_REPO_ID'" \
        -c "\copy public.gosec_repo_scans (repo_id, issues) FROM stdin (FORMAT csv)";
