CREATE TABLE IF NOT EXISTS trufflehog_repo_scans (
  repo_id uuid PRIMARY KEY REFERENCES repos(id) ON DELETE CASCADE ON UPDATE RESTRICT,
  results jsonb NOT NULL,
  _mergestat_synced_at timestamp with time zone NOT NULL DEFAULT now()
);
COMMENT ON TABLE  trufflehog_repo_scans IS 'Trufflehog repo scans';
COMMENT ON COLUMN trufflehog_repo_scans.repo_id IS 'foreign key for public.repos.id';
COMMENT ON COLUMN trufflehog_repo_scans.results IS 'JSON results from Trufflehog repo scan';
COMMENT ON COLUMN trufflehog_repo_scans._mergestat_synced_at IS 'timestamp when record was synced into the MergeStat database';

CREATE UNIQUE INDEX IF NOT EXISTS trufflehog_repo_scans_pkey ON trufflehog_repo_scans(repo_id uuid_ops);
CREATE INDEX IF NOT EXISTS idx_trufflehog_repo_id_fkey ON trufflehog_repo_scans(repo_id uuid_ops);
