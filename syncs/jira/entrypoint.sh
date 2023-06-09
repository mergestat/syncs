#!/bin/bash
set -euo pipefail

export NO_COLOR=true
export MELTANO_ENVIRONMENT=mergestat

# Trim leading and trailing whitespaces
trim() {
  local var="$*"
  var="${var#"${var%%[![:space:]]*}"}"   # remove leading whitespaces
  var="${var%"${var##*[![:space:]]}"}"   # remove trailing whitespaces
  echo -n "$var"
}

# setup table schema
psql $MERGESTAT_POSTGRES_URL --quiet -1 -c 'CREATE TABLE IF NOT EXISTS mergestat.tap_states(repo UUID, tap TEXT, state JSON, PRIMARY KEY(repo, tap), FOREIGN KEY (repo) REFERENCES public.repos (id))';

# fetch and restore json state
psql $MERGESTAT_POSTGRES_URL --quiet -t -c "SELECT state FROM mergestat.tap_states WHERE repo = '$MERGESTAT_REPO_ID' AND tap = 'mergestat:tap-jira-to-target-postgres'" > .meltano/_state.json

# Load state from file
if [ -s '.meltano/_state.json' ] && [ -n "$(trim "$(cat '.meltano/_state.json')")" ]; then  
  cat '.meltano/_state.json' | meltano state set mergestat:tap-jira-to-target-postgres --input-file /dev/stdin --force
fi

meltano run tap-jira target-postgres

# save state
meltano state get mergestat:tap-jira-to-target-postgres > .meltano/_state.json
psql $MERGESTAT_POSTGRES_URL --quiet -1 \
  -c "INSERT INTO mergestat.tap_states (repo, tap, state) \
      VALUES ('$MERGESTAT_REPO_ID', 'mergestat:tap-jira-to-target-postgres', '$(cat .meltano/_state.json)') ON CONFLICT (repo, tap) DO UPDATE SET state = EXCLUDED.state";
