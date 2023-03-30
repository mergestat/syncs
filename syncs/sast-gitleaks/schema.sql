CREATE TABLE IF NOT EXISTS gitleaks_repo_scans (
  repo_id uuid PRIMARY KEY REFERENCES repos(id) ON DELETE CASCADE ON UPDATE RESTRICT,
  results jsonb NOT NULL
);
COMMENT ON TABLE gitleaks_repo_scans IS 'scan output of a Gitleaks repo scan';
COMMENT ON COLUMN gitleaks_repo_scans.repo_id IS 'foreign key for public.repos.id';
COMMENT ON COLUMN gitleaks_repo_scans.results IS 'JSON output of a Gitleaks scan';

CREATE UNIQUE INDEX IF NOT EXISTS gitleaks_repo_scans_pkey ON gitleaks_repo_scans(repo_id uuid_ops);

CREATE OR REPLACE VIEW gitleaks_repo_detections AS  SELECT gitleaks_repo_scans.repo_id,
    r.value ->> 'Description'::text AS description,
    r.value ->> 'StartLine'::text AS start_line,
    r.value ->> 'EndLine'::text AS end_line,
    r.value ->> 'StartColumn'::text AS start_column,
    r.value ->> 'EndColumn'::text AS end_column,
    r.value ->> 'Match'::text AS match,
    r.value ->> 'Secret'::text AS secret,
    r.value ->> 'File'::text AS file,
    r.value ->> 'SymlinkFile'::text AS symlink_file,
    r.value ->> 'Commit'::text AS commit,
    r.value ->> 'Entropy'::text AS entropy,
    r.value ->> 'Author'::text AS author,
    r.value ->> 'Email'::text AS email,
    r.value ->> 'Date'::text AS date,
    r.value ->> 'Message'::text AS message,
    r.value ->> 'Tags'::text AS tags,
    r.value ->> 'RuleID'::text AS rule_id,
    r.value ->> 'Fingerprint'::text AS fingerprint
   FROM gitleaks_repo_scans,
    LATERAL jsonb_array_elements(gitleaks_repo_scans.results) r(value);

COMMENT ON VIEW gitleaks_repo_detections IS 'view of Gitleaks repo scan detections';
COMMENT ON COLUMN gitleaks_repo_detections.repo_id IS 'foreign key for public.repos.id';
COMMENT ON COLUMN gitleaks_repo_detections.description IS 'description of the detection';
COMMENT ON COLUMN gitleaks_repo_detections.start_line IS 'detection start line';
COMMENT ON COLUMN gitleaks_repo_detections.end_line IS 'detection end line';
COMMENT ON COLUMN gitleaks_repo_detections.start_column IS 'detection start column';
COMMENT ON COLUMN gitleaks_repo_detections.end_column IS 'detection end column';
COMMENT ON COLUMN gitleaks_repo_detections.match IS 'detection match';
COMMENT ON COLUMN gitleaks_repo_detections.secret IS 'detection secret';
COMMENT ON COLUMN gitleaks_repo_detections.file IS 'detection file';
COMMENT ON COLUMN gitleaks_repo_detections.symlink_file IS 'detected symlink file';
COMMENT ON COLUMN gitleaks_repo_detections.commit IS 'detection commit';
COMMENT ON COLUMN gitleaks_repo_detections.entropy IS 'detection entropy';
COMMENT ON COLUMN gitleaks_repo_detections.author IS 'detection author';
COMMENT ON COLUMN gitleaks_repo_detections.email IS 'detection email';
COMMENT ON COLUMN gitleaks_repo_detections.date IS 'detection date';
COMMENT ON COLUMN gitleaks_repo_detections.message IS 'detection message';
COMMENT ON COLUMN gitleaks_repo_detections.tags IS 'detection tags';
COMMENT ON COLUMN gitleaks_repo_detections.rule_id IS 'detection rule id';
COMMENT ON COLUMN gitleaks_repo_detections.fingerprint IS 'detection fingerprint';
