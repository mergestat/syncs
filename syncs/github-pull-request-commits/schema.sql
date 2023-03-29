-- SQL migration to setup schema for github-pull-request-commits

CREATE TABLE IF NOT EXISTS github_pull_request_commits (
    repo_id uuid REFERENCES repos(id) ON DELETE CASCADE ON UPDATE RESTRICT,
    pr_number integer,
    hash text,
    message text,
    author_name text,
    author_email text,
    author_when timestamp with time zone,
    committer_name text,
    committer_email text,
    committer_when timestamp with time zone,
    additions integer,
    deletions integer,
    changed_files integer,
    url text,
    _mergestat_synced_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT github_pull_request_commits_pkey PRIMARY KEY (repo_id, pr_number, hash)
);

COMMENT ON TABLE github_pull_request_commits IS 'commits for all pull requests of a GitHub repo';
COMMENT ON COLUMN github_pull_request_commits.repo_id IS 'foreign key for public.repos.id';
COMMENT ON COLUMN github_pull_request_commits.pr_number IS 'GitHub pull request number of the commit';
COMMENT ON COLUMN github_pull_request_commits.hash IS 'hash of the commit';
COMMENT ON COLUMN github_pull_request_commits.message IS 'message of the commit';
COMMENT ON COLUMN github_pull_request_commits.author_name IS 'name of the author of the the modification';
COMMENT ON COLUMN github_pull_request_commits.author_email IS 'email of the author of the modification';
COMMENT ON COLUMN github_pull_request_commits.author_when IS 'timestamp of when the modifcation was authored';
COMMENT ON COLUMN github_pull_request_commits.committer_name IS 'name of the author who committed the modification';
COMMENT ON COLUMN github_pull_request_commits.committer_email IS 'email of the author who committed the modification';
COMMENT ON COLUMN github_pull_request_commits.committer_when IS 'timestamp of when the commit was made';
COMMENT ON COLUMN github_pull_request_commits.additions IS 'the number of additions in the commit';
COMMENT ON COLUMN github_pull_request_commits.deletions IS 'the number of deletions in the commit';
COMMENT ON COLUMN github_pull_request_commits.changed_files IS 'the number of files changed/modified in the commit';
COMMENT ON COLUMN github_pull_request_commits.url IS 'GitHub URL of the commit';
COMMENT ON COLUMN github_pull_request_commits._mergestat_synced_at IS 'timestamp when record was synced into the MergeStat database';


CREATE UNIQUE INDEX IF NOT EXISTS github_pull_request_commits_pkey ON github_pull_request_commits(repo_id uuid_ops,pr_number int4_ops,hash text_ops);
CREATE INDEX IF NOT EXISTS idx_request_commits_repo_id_fkey ON github_pull_request_commits(repo_id uuid_ops);
