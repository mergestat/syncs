#!/bin/bash
set -euo pipefail
meltano --environment mergestat run tap-jira target-postgres