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
