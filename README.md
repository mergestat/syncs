# @mergestat/syncs

[![Twitter Follow](https://img.shields.io/twitter/follow/mergestat)](https://twitter.com/mergestat)
[![Slack Community](https://badgen.net/badge/icon/slack?icon=slack&label)](https://join.slack.com/t/mergestatcommunity/shared_invite/zt-xvvtvcz9-w3JJVIdhLgEWrVrKKNXOYg)

This repository provides officially supported **syncs** for [**`mergestat`**](https://github.com/mergestat/mergestat).

## About

[MergeStat](https://www.mergestat.com/) syncs are programs packaged in containers that run a process or analysis on a Git repository, and typically store the results in postgres for downstream querying and analysis.

They are orchestrated and run in the context of a [`mergestat`](https://github.com/mergestat/mergestat) instance.

For example, the `git-commits` sync in `syncs/git-commits` will retrieve the full commit history of a repo and store information about each commit in postgres.
This allows for subsequent querying of the commit history of a repo, across all the repos this sync has run on.

## License

MIT License Copyright (c) 2023 AskGit, Inc. Refer to [`LICENSE`](./LICENSE) for full text.
