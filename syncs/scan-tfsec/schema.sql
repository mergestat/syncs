CREATE TABLE IF NOT EXISTS tfsec_repo_scans (
    repo_id uuid PRIMARY KEY REFERENCES repos(id) ON DELETE CASCADE ON UPDATE RESTRICT,
    results jsonb NOT NULL,
    _mergestat_synced_at timestamp with time zone NOT NULL DEFAULT now()
);
COMMENT ON TABLE tfsec_repo_scans IS 'Table of tfsec repo scans';
COMMENT ON COLUMN tfsec_repo_scans.repo_id IS 'foreign key for public.repos.id';
COMMENT ON COLUMN tfsec_repo_scans.results IS 'JSON results from tfsec repo scan';
COMMENT ON COLUMN tfsec_repo_scans._mergestat_synced_at IS 'timestamp when record was synced into the MergeStat database';

DROP VIEW IF EXISTS tfsec_repo_issues;
CREATE VIEW tfsec_repo_issues AS  SELECT tfsec_repo_scans.repo_id,
    r.value ->> 'impact'::text AS impact,
    r.value ->> 'status'::text AS status,
    r.value ->> 'long_id'::text AS long_id,
    r.value ->> 'rule_id'::text AS rule_id,
    r.value ->> 'warning'::text AS warning,
    (r.value -> 'location'::text) ->> 'start_line'::text AS location_start_line,
    (r.value -> 'location'::text) ->> 'end_line'::text AS location_end_line,
    (r.value -> 'location'::text) ->> 'filename'::text AS location_filename,
    r.value ->> 'resource'::text AS resource,
    r.value ->> 'severity'::text AS severity,
    r.value ->> 'resolution'::text AS resolution,
    r.value ->> 'description'::text AS description,
    r.value ->> 'rule_service'::text AS rule_service,
    r.value ->> 'rule_provider'::text AS rule_provider,
    r.value ->> 'rule_description'::text AS rule_description,
    r.value AS issue,
    tfsec_repo_scans._mergestat_synced_at
   FROM tfsec_repo_scans,
    LATERAL jsonb_array_elements(tfsec_repo_scans.results -> 'results'::text) r(value);

COMMENT ON VIEW tfsec_repo_issues IS 'List of tfsec repo issues';
-- TODO(patrickdevivo): document the columns in the view
