CREATE TABLE IF NOT EXISTS osv_repo_scans (
  repo_id uuid PRIMARY KEY REFERENCES repos(id) ON DELETE CASCADE ON UPDATE RESTRICT,
  results jsonb NOT NULL,
  _mergestat_synced_at timestamp with time zone NOT NULL DEFAULT now()
);
COMMENT ON TABLE osv_repo_scans IS 'OSV repo scans';
COMMENT ON COLUMN osv_repo_scans.repo_id IS 'foreign key for public.repos.id';
COMMENT ON COLUMN osv_repo_scans.results IS 'JSON results from OSV repo scan';
COMMENT ON COLUMN osv_repo_scans._mergestat_synced_at IS 'timestamp when record was synced into the MergeStat database';

CREATE UNIQUE INDEX IF NOT EXISTS osv_repo_scans_pkey ON osv_repo_scans(repo_id uuid_ops);
CREATE INDEX IF NOT EXISTS idx_osv_repo_id_fkey ON osv_repo_scans(repo_id uuid_ops);
