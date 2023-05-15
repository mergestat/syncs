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

DROP VIEW IF EXISTS osv_vulnerabilities;
CREATE OR REPLACE VIEW osv_vulnerabilities AS SELECT repos.id AS repo_id,
    repos.repo,
    (p.value -> 'package'::text) ->> 'name'::text AS pkg_name,
    (p.value -> 'package'::text) ->> 'version'::text AS pkg_version,
    (p.value -> 'package'::text) ->> 'ecosystem'::text AS pkg_ecosystem,
    (v.value -> 'database_specific'::text) ->> 'severity'::text AS sev,
    v.value ->> 'id'::text AS id,
    v.value ->> 'details'::text AS details,
    (v.value ->> 'published'::text)::timestamp with time zone AS published,
    p.value AS package,
    v.value AS vulnerability
   FROM osv_repo_scans
     JOIN repos ON repos.id = osv_repo_scans.repo_id,
    LATERAL jsonb_array_elements(osv_repo_scans.results -> 'results'::text) r(value),
    LATERAL jsonb_array_elements(r.value -> 'packages'::text) p(value),
    LATERAL jsonb_array_elements(p.value -> 'vulnerabilities'::text) v(value);
COMMENT ON VIEW osv_vulnerabilities IS 'OSV repo scan vulnerabilities';
COMMENT ON COLUMN osv_vulnerabilities.repo_id IS 'foreign key for public.repos.id';
-- TODO(patrickdevivo) finish documenting these columns...
