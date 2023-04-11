CREATE TABLE IF NOT EXISTS trivy_repo_scans (
    repo_id uuid PRIMARY KEY REFERENCES repos(id) ON DELETE CASCADE ON UPDATE RESTRICT,
    results jsonb NOT NULL,
    _mergestat_synced_at timestamp with time zone NOT NULL DEFAULT now()
);
COMMENT ON TABLE trivy_repo_scans IS 'Trivy repo scans';
COMMENT ON COLUMN trivy_repo_scans.repo_id IS 'foreign key for public.repos.id';
COMMENT ON COLUMN trivy_repo_scans.results IS 'JSON results from Trivy repo scan';
COMMENT ON COLUMN trivy_repo_scans._mergestat_synced_at IS 'timestamp when record was synced into the MergeStat database';

CREATE UNIQUE INDEX IF NOT EXISTS trivy_repo_scans_pkey ON trivy_repo_scans(repo_id uuid_ops);
CREATE INDEX IF NOT EXISTS idx_trivy_repo_id_fkey ON trivy_repo_scans(repo_id uuid_ops);


CREATE OR REPLACE VIEW trivy_repo_vulnerabilities AS  SELECT trivy_repo_scans.repo_id,
    v.value AS vulnerability,
    r.value ->> 'Target'::text AS target,
    r.value ->> 'Class'::text AS class,
    r.value ->> 'Type'::text AS type,
    v.value ->> 'VulnerabilityID'::text AS vulnerability_id,
    v.value ->> 'PkgName'::text AS vulnerability_pkg_name,
    v.value ->> 'InstalledVersion'::text AS vulnerability_installed_version,
    v.value ->> 'Severity'::text AS vulnerability_severity,
    v.value ->> 'Title'::text AS vulnerability_title,
    v.value ->> 'Description'::text AS vulnerability_description,
    trivy_repo_scans._mergestat_synced_at
   FROM trivy_repo_scans,
    LATERAL jsonb_array_elements(trivy_repo_scans.results -> 'Results'::text) r(value),
    LATERAL jsonb_array_elements(r.value -> 'Vulnerabilities'::text) v(value);
COMMENT ON VIEW trivy_repo_vulnerabilities IS 'view of Trivy repo scans vulnerabilities';
COMMENT ON COLUMN trivy_repo_vulnerabilities.repo_id IS 'foreign key for public.repos.id';
COMMENT ON COLUMN trivy_repo_vulnerabilities.vulnerability IS 'vulnerability JSON results of Trivy scan';
COMMENT ON COLUMN trivy_repo_vulnerabilities.target IS 'vulnerability target';
COMMENT ON COLUMN trivy_repo_vulnerabilities.class IS 'vulnerability class';
COMMENT ON COLUMN trivy_repo_vulnerabilities.type IS 'vulnerability type';
COMMENT ON COLUMN trivy_repo_vulnerabilities.vulnerability_id IS 'vulnerability id';
COMMENT ON COLUMN trivy_repo_vulnerabilities.vulnerability_pkg_name IS 'vulnerability package name';
COMMENT ON COLUMN trivy_repo_vulnerabilities.vulnerability_installed_version IS 'vulnerability installed version';
COMMENT ON COLUMN trivy_repo_vulnerabilities.vulnerability_severity IS 'vulnerability severity';
COMMENT ON COLUMN trivy_repo_vulnerabilities.vulnerability_title IS 'vulnerability title';
COMMENT ON COLUMN trivy_repo_vulnerabilities.vulnerability_description IS 'vulnerability description';
COMMENT ON COLUMN trivy_repo_vulnerabilities._mergestat_synced_at IS 'timestamp when record was synced into the MergeStat database';
