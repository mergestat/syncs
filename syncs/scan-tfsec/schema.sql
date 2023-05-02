CREATE TABLE IF NOT EXISTS tfsec_repo_scans (
    repo_id uuid PRIMARY KEY REFERENCES repos(id) ON DELETE CASCADE ON UPDATE RESTRICT,
    results jsonb NOT NULL,
    _mergestat_synced_at timestamp with time zone NOT NULL DEFAULT now()
);
COMMENT ON TABLE tfsec_repo_scans IS 'Table of tfsec repo scans';
COMMENT ON COLUMN tfsec_repo_scans.repo_id IS 'foreign key for public.repos.id';
COMMENT ON COLUMN tfsec_repo_scans.results IS 'JSON results from tfsec repo scan';
COMMENT ON COLUMN tfsec_repo_scans._mergestat_synced_at IS 'timestamp when record was synced into the MergeStat database';
