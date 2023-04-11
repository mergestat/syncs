CREATE TABLE IF NOT EXISTS public.grype_repo_scans (
    repo_id uuid PRIMARY KEY REFERENCES repos(id) ON DELETE CASCADE ON UPDATE RESTRICT,
    results jsonb NOT NULL,
    _mergestat_synced_at timestamp with time zone NOT NULL DEFAULT now()
);
COMMENT ON TABLE grype_repo_scans IS 'Table for Grype repo scan results';
COMMENT ON COLUMN grype_repo_scans.repo_id IS 'foreign key for public.repos.id';
COMMENT ON COLUMN grype_repo_scans.results IS 'JSON results of Grype repo scanner';
COMMENT ON COLUMN grype_repo_scans._mergestat_synced_at IS 'timestamp when record was synced into the MergeStat database';

CREATE UNIQUE INDEX IF NOT EXISTS grype_repo_scans_pkey ON grype_repo_scans(repo_id uuid_ops);

CREATE OR REPLACE VIEW public.grype_repo_vulnerabilities AS  SELECT DISTINCT grype_repo_scans.repo_id,
    (m.value -> 'vulnerability'::text) ->> 'id'::text AS id,
    (m.value -> 'vulnerability'::text) ->> 'severity'::text AS severity,
    (m.value -> 'vulnerability'::text) ->> 'description'::text AS description,
    (m.value -> 'artifact'::text) ->> 'version'::text AS version,
    (m.value -> 'artifact'::text) ->> 'type'::text AS type,
    (m.value -> 'artifact'::text) ->> 'language'::text AS language,
    l.value ->> 'path'::text AS path
   FROM grype_repo_scans,
    LATERAL jsonb_array_elements(grype_repo_scans.results -> 'matches'::text) m(value),
    LATERAL jsonb_array_elements((m.value -> 'artifact'::text) -> 'locations'::text) l(value);
COMMENT ON VIEW grype_repo_vulnerabilities IS 'view of Grype repo scans results';
COMMENT ON COLUMN grype_repo_vulnerabilities.repo_id IS 'foreign key for public.repos.id';
COMMENT ON COLUMN grype_repo_vulnerabilities.id IS 'id of the current vulnerability';
COMMENT ON COLUMN grype_repo_vulnerabilities.severity IS 'level of severity';
COMMENT ON COLUMN grype_repo_vulnerabilities.description IS 'description  of vulnerability';
COMMENT ON COLUMN grype_repo_vulnerabilities.version IS 'current version of package vulnerable';
COMMENT ON COLUMN grype_repo_vulnerabilities.type IS 'type of vulnerability';
COMMENT ON COLUMN grype_repo_vulnerabilities.language IS 'programming language associated to vulnerability';
COMMENT ON COLUMN grype_repo_vulnerabilities.path IS 'path to file of current vulnerability';
