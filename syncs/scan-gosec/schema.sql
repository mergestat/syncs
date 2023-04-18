CREATE TABLE IF NOT EXISTS gosec_repo_scans (
    repo_id uuid PRIMARY KEY REFERENCES repos(id) ON DELETE CASCADE ON UPDATE RESTRICT,
    issues jsonb NOT NULL,
    _mergestat_synced_at timestamp with time zone NOT NULL DEFAULT now()
);
COMMENT ON TABLE gosec_repo_scans IS 'Table of gosec repo scans';
COMMENT ON COLUMN gosec_repo_scans.repo_id IS 'foreign key for public.repos.id';
COMMENT ON COLUMN gosec_repo_scans.issues IS 'JSON issues from gosec repo scan';
COMMENT ON COLUMN gosec_repo_scans._mergestat_synced_at IS 'timestamp when record was synced into the MergeStat database';

CREATE UNIQUE INDEX IF NOT EXISTS gosec_repo_scans_pkey ON gosec_repo_scans(repo_id uuid_ops);

CREATE OR REPLACE VIEW gosec_repo_detections AS SELECT gosec_repo_scans.repo_id,
    issue.value ->> 'severity'::text AS severity,
    issue.value ->> 'confidence'::text AS confidence,
    (issue.value -> 'cwe'::text) ->> 'id'::text AS cwe_id,
    issue.value ->> 'rule_id'::text AS rule_id,
    issue.value ->> 'details'::text AS details,
    issue.value ->> 'file'::text AS file,
    issue.value ->> 'line'::text AS line,
    issue.value ->> 'column'::text AS "column",
    issue.value ->> 'nosec'::text AS nosec
   FROM gosec_repo_scans,
    LATERAL jsonb_array_elements(gosec_repo_scans.issues) issue(value);
COMMENT ON VIEW gosec_repo_detections IS 'view of gosec repo scan detections';
COMMENT ON COLUMN gosec_repo_detections.repo_id IS 'foreign key for public.repos.id';
COMMENT ON COLUMN gosec_repo_detections.severity IS 'detection severity';
COMMENT ON COLUMN gosec_repo_detections.confidence IS 'detection confidence';
COMMENT ON COLUMN gosec_repo_detections.cwe_id IS 'detection CWE (Common Weakness Enumeration) ID';
COMMENT ON COLUMN gosec_repo_detections.rule_id IS 'detection rule ID';
COMMENT ON COLUMN gosec_repo_detections.details IS 'detection details';
COMMENT ON COLUMN gosec_repo_detections.file IS 'detection file';
COMMENT ON COLUMN gosec_repo_detections.line IS 'detection line in file';
COMMENT ON COLUMN gosec_repo_detections."column" IS 'detection column in line';
COMMENT ON COLUMN gosec_repo_detections.nosec IS 'flag to determine if #nosec annotation was used';
