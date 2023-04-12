CREATE TABLE IF NOT EXISTS git_commit_stats (
    repo_id uuid REFERENCES repos(id) ON DELETE CASCADE ON UPDATE RESTRICT,
    commit_hash text,
    file_path text,
    additions integer NOT NULL,
    deletions integer NOT NULL,
    _mergestat_synced_at timestamp with time zone NOT NULL DEFAULT now(),
    old_file_mode text NOT NULL DEFAULT 'unknown'::text,
    new_file_mode text DEFAULT 'unknown'::text,
    CONSTRAINT commit_stats_pkey PRIMARY KEY (repo_id, file_path, commit_hash, new_file_mode)
);
COMMENT ON TABLE git_commit_stats IS 'git commit stats of a repo';
COMMENT ON COLUMN git_commit_stats.repo_id IS 'foreign key for public.repos.id';
COMMENT ON COLUMN git_commit_stats.commit_hash IS 'hash of the commit';
COMMENT ON COLUMN git_commit_stats.file_path IS 'path of the file the modification was made in';
COMMENT ON COLUMN git_commit_stats.additions IS 'the number of additions in this path of the commit';
COMMENT ON COLUMN git_commit_stats.deletions IS 'the number of deletions in this path of the commit';
COMMENT ON COLUMN git_commit_stats._mergestat_synced_at IS 'timestamp when record was synced into the MergeStat database';
COMMENT ON COLUMN git_commit_stats.old_file_mode IS 'old file mode derived from git mode. possible values (unknown, none, regular_file, symbolic_link, git_link)';
COMMENT ON COLUMN git_commit_stats.new_file_mode IS 'new file mode derived from git mode. possible values (unknown, none, regular_file, symbolic_link, git_link)';

CREATE UNIQUE INDEX IF NOT EXISTS commit_stats_pkey ON git_commit_stats(repo_id uuid_ops,file_path text_ops,commit_hash text_ops,new_file_mode text_ops);
CREATE INDEX IF NOT EXISTS idx_commit_stats_repo_id_fkey ON git_commit_stats(repo_id uuid_ops);
