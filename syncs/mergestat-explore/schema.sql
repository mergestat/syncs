-- SQL migration to setup schema for mergestat-explore

-- git_commits
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


-- git_commit_stats
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

-- git_files
CREATE TABLE IF NOT EXISTS git_files (
    repo_id uuid REFERENCES repos(id) ON DELETE CASCADE ON UPDATE RESTRICT,
    path text,
    executable boolean NOT NULL,
    contents text,
    _mergestat_synced_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT files_pkey PRIMARY KEY (repo_id, path)
);
COMMENT ON TABLE git_files IS 'git files (content and paths) of a repo';
COMMENT ON COLUMN git_files.repo_id IS 'foreign key for public.repos.id';
COMMENT ON COLUMN git_files.path IS 'path of the file';
COMMENT ON COLUMN git_files.executable IS 'boolean to determine if the file is an executable';
COMMENT ON COLUMN git_files.contents IS 'contents of the file';
COMMENT ON COLUMN git_files._mergestat_synced_at IS 'timestamp when record was synced into the MergeStat database';

CREATE UNIQUE INDEX IF NOT EXISTS files_pkey ON git_files(repo_id uuid_ops,path text_ops);
CREATE INDEX IF NOT EXISTS idx_files_repo_id_fkey ON git_files(repo_id uuid_ops);

-- _mergestat_explore_repo_metadata
CREATE TABLE IF NOT EXISTS _mergestat_explore_repo_metadata (
    repo_id uuid REFERENCES repos(id) ON DELETE CASCADE ON UPDATE RESTRICT,
    last_commit_hash text,
    CONSTRAINT _mergestat_explore_repo_metadata_pkey PRIMARY KEY (repo_id)
)

COMMENT ON TABLE _mergestat_explore_repo_metadata IS 'repo metadata for explore experience';
COMMENT ON COLUMN _mergestat_explore_repo_metadata.repo_id IS 'foreign key for public.repos.id';
COMMENT ON COLUMN _mergestat_explore_repo_metadata.last_commit_hash IS 'hash based reference to last commit';

-- _mergestat_explore_file_metadata
CREATE TABLE IF NOT EXISTS _mergestat_explore_file_metadata (
    repo_id uuid REFERENCES repos(id) ON DELETE CASCADE ON UPDATE RESTRICT,
    path text,
    last_commit_hash text,
    CONSTRAINT _mergestat_explore_repo_metadata_pkey PRIMARY KEY (repo_id, path)
)

COMMENT ON TABLE _mergestat_explore_file_metadata IS 'file metadata for explore experience';
COMMENT ON COLUMN _mergestat_explore_file_metadata.repo_id IS 'foreign key for public.repos.id';
COMMENT ON COLUMN _mergestat_explore_file_metadata.path IS 'path to the file';
COMMENT ON COLUMN _mergestat_explore_file_metadata.last_commit_hash IS 'hash based reference to last commit';
