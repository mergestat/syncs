CREATE TABLE IF NOT EXISTS yelp_detect_secrets_repo_scans (
  repo_id uuid PRIMARY KEY REFERENCES repos(id) ON DELETE CASCADE ON UPDATE RESTRICT,
  results jsonb NOT NULL
);

COMMENT ON TABLE yelp_detect_secrets_repo_scans IS 'scan output of a Yelp detect-secrets repo scan';
COMMENT ON COLUMN yelp_detect_secrets_repo_scans.repo_id IS 'foreign key for public.repos.id';
COMMENT ON COLUMN yelp_detect_secrets_repo_scans.results IS 'JSON output of a Yelp detect-secrets scan';

CREATE UNIQUE INDEX IF NOT EXISTS yelp_detect_secrets_repo_scans_pkey ON yelp_detect_secrets_repo_scans(repo_id uuid_ops);

CREATE OR REPLACE VIEW yelp_detect_secrets_repo_detections AS  SELECT yelp_detect_secrets_repo_scans.repo_id,
    r.value[0] ->> 'type'::text AS type,
    r.value[0] ->> 'filename'::text AS filename,
    r.value[0] ->> 'is_verified'::text AS is_verified,
    r.value[0] ->> 'line_number'::text AS line_number,
    r.value[0] ->> 'hashed_secret'::text AS hashed_secret,
    yelp_detect_secrets_repo_scans.results ->> 'version'::text AS version,
    yelp_detect_secrets_repo_scans.results ->> 'generated_at'::text AS generated_at,
    yelp_detect_secrets_repo_scans.results ->> 'filters_used'::text AS filters_used,
    yelp_detect_secrets_repo_scans.results ->> 'plugins_used'::text AS plugins_used
   FROM yelp_detect_secrets_repo_scans,
    LATERAL jsonb_each(yelp_detect_secrets_repo_scans.results -> 'results'::text) r(key, value);
    
COMMENT ON COLUMN yelp_detect_secrets_repo_detections.repo_id IS 'foreign key for public.repos.id';
COMMENT ON COLUMN yelp_detect_secrets_repo_detections.type IS 'detection type';
COMMENT ON COLUMN yelp_detect_secrets_repo_detections.filename IS 'detection filename';
COMMENT ON COLUMN yelp_detect_secrets_repo_detections.is_verified IS 'detection is verified';
COMMENT ON COLUMN yelp_detect_secrets_repo_detections.line_number IS 'detection line number';
COMMENT ON COLUMN yelp_detect_secrets_repo_detections.hashed_secret IS 'detection secret';
COMMENT ON COLUMN yelp_detect_secrets_repo_detections.version IS 'detection version';
COMMENT ON COLUMN yelp_detect_secrets_repo_detections.generated_at IS 'detection generated at';
COMMENT ON COLUMN yelp_detect_secrets_repo_detections.filters_used IS 'detection filters used';
COMMENT ON COLUMN yelp_detect_secrets_repo_detections.plugins_used IS 'detection plugins used';
