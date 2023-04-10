-- SQL migration to setup schema for git-commits sync

CREATE TABLE IF NOT EXISTS git_commits (
    repo_id uuid REFERENCES repos(id) ON DELETE CASCADE ON UPDATE RESTRICT,
    hash text,
    message text NOT NULL,
    author_name text NOT NULL,
    author_email text NOT NULL,
    author_when timestamp with time zone NOT NULL,
    committer_name text NOT NULL,
    committer_email text NOT NULL,
    committer_when timestamp with time zone NOT NULL,
    parents integer NOT NULL,
    _mergestat_synced_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT commits_pkey PRIMARY KEY (repo_id, hash)
);
COMMENT ON TABLE git_commits IS 'git commit history of a repo';
COMMENT ON COLUMN git_commits.repo_id IS 'foreign key for public.repos.id';
COMMENT ON COLUMN git_commits.hash IS 'hash of the commit';
COMMENT ON COLUMN git_commits.message IS 'message of the commit';
COMMENT ON COLUMN git_commits.author_name IS 'name of the author of the the modification';
COMMENT ON COLUMN git_commits.author_email IS 'email of the author of the modification';
COMMENT ON COLUMN git_commits.author_when IS 'timestamp of when the modifcation was authored';
COMMENT ON COLUMN git_commits.committer_name IS 'name of the author who committed the modification';
COMMENT ON COLUMN git_commits.committer_email IS 'email of the author who committed the modification';
COMMENT ON COLUMN git_commits.committer_when IS 'timestamp of when the commit was made';
COMMENT ON COLUMN git_commits.parents IS 'the number of parents of the commit';
COMMENT ON COLUMN git_commits._mergestat_synced_at IS 'timestamp when record was synced into the MergeStat database';


CREATE UNIQUE INDEX IF NOT EXISTS commits_pkey ON git_commits(repo_id uuid_ops,hash text_ops);
CREATE INDEX IF NOT EXISTS commits_author_when_idx ON git_commits(repo_id uuid_ops,author_when timestamptz_ops);
CREATE INDEX IF NOT EXISTS idx_commits_repo_id_fkey ON git_commits(repo_id uuid_ops);
