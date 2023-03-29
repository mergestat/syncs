-- SQL migration to setup schema for git-blame syncer

CREATE TABLE IF NOT EXISTS git_blame (
    repo_id uuid REFERENCES repos(id) ON DELETE CASCADE ON UPDATE RESTRICT,
    author_email text,
    author_name text,
    author_when timestamp with time zone,
    commit_hash text,
    line_no integer,
    line text,
    path text,
    _mergestat_synced_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT git_blame_pkey PRIMARY KEY (repo_id, path, line_no)
);

COMMENT ON TABLE git_blame IS 'git blame of all lines in all files of a repo';
COMMENT ON COLUMN git_blame.repo_id IS 'foreign key for public.repos.id';
COMMENT ON COLUMN git_blame.author_email IS 'email of the author who modified the line';
COMMENT ON COLUMN git_blame.author_name IS 'name of the author who modified the line';
COMMENT ON COLUMN git_blame.commit_hash IS 'hash of the commit the modification was made in';
COMMENT ON COLUMN git_blame.line_no IS 'line number of the modification';
COMMENT ON COLUMN git_blame.path IS 'path of the file the modification was made in';
COMMENT ON COLUMN git_blame._mergestat_synced_at IS 'timestamp when record was synced into the MergeStat database';

CREATE UNIQUE INDEX IF NOT EXISTS git_blame_pkey ON git_blame(repo_id uuid_ops,path text_ops,line_no int4_ops);
CREATE INDEX IF NOT EXISTS idx_git_blame_repo_id_fkey ON git_blame(repo_id uuid_ops);
