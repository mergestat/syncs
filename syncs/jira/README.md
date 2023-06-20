# @mergestat/sync-jira

`@mergestat/sync-jira` sync tickets / issues from [**Atlassian Jira**](https://www.atlassian.com/software/jira).

## Usage

To use this sync, create a new container-based sync in mergestat using `ghcr.io/mergestat/sync-jira` container image and specify the following variables (using parameter override):

- `JIRA_BASE_URL`: base url for your instance, eg. `mergestat.atlassian.net`
- `JIRA_START_DATE`: to use as the start date from which you want to fetch the data
- `JIRA_USERNAME`: to specify your username / email
- `JIRA_PASSWORD`: to specify your [Atlassian `Personal Access Token`](https://confluence.atlassian.com/enterprise/using-personal-access-tokens-1026032365.html)

## Caveats

Currently, this sync only works with either Postgres v14 with implicit authentication. To use it with password-based authentication, use Postgres v13 or below. 
This is being tracked under mergestat/syncs#80
