CREATE TABLE IF NOT EXISTS public.syft_repo_scans (
    repo_id uuid PRIMARY KEY REFERENCES repos(id) ON DELETE CASCADE ON UPDATE RESTRICT,
    results jsonb NOT NULL,
    _mergestat_synced_at timestamp with time zone NOT NULL DEFAULT now()
);

COMMENT ON TABLE syft_repo_scans IS 'Syft repo scans';
COMMENT ON COLUMN syft_repo_scans.repo_id IS 'foreign key for public.repos.id';
COMMENT ON COLUMN syft_repo_scans.results IS 'JSON results from Syft repo scan';
COMMENT ON COLUMN syft_repo_scans._mergestat_synced_at IS 'timestamp when record was synced into the MergeStat database';

CREATE UNIQUE INDEX IF NOT EXISTS syft_repo_scans_pkey ON syft_repo_scans(repo_id uuid_ops);

CREATE OR REPLACE VIEW syft_repo_artifacts AS  SELECT syft_repo_scans.repo_id,
    a.value AS artifact,
    a.value ->> 'id'::text AS id,
    a.value ->> 'name'::text AS name,
    a.value ->> 'version'::text AS version,
    a.value ->> 'type'::text AS type,
    a.value ->> 'foundBy'::text AS found_by,
    a.value ->> 'locations'::text AS locations,
    a.value ->> 'licenses'::text AS licenses,
    a.value ->> 'language'::text AS language,
    a.value ->> 'cpes'::text AS cpes,
    a.value ->> 'purl'::text AS purl
   FROM syft_repo_scans,
    LATERAL jsonb_array_elements(syft_repo_scans.results -> 'artifacts'::text) a(value);
COMMENT ON VIEW syft_repo_artifacts IS 'view of Syft repo scans artifacts';
COMMENT ON COLUMN syft_repo_artifacts.repo_id IS 'foreign key for public.repos.id';
COMMENT ON COLUMN syft_repo_artifacts.artifact IS 'artifact JSON results from Syft repo scan';
COMMENT ON COLUMN syft_repo_artifacts.id IS 'artifact id';
COMMENT ON COLUMN syft_repo_artifacts.name IS 'artifact name';
COMMENT ON COLUMN syft_repo_artifacts.version IS 'artifact version';
COMMENT ON COLUMN syft_repo_artifacts.type IS 'artifact type';
COMMENT ON COLUMN syft_repo_artifacts.found_by IS 'artifact found_by';
COMMENT ON COLUMN syft_repo_artifacts.locations IS 'artifact locations';
COMMENT ON COLUMN syft_repo_artifacts.licenses IS 'artifact licenses';
COMMENT ON COLUMN syft_repo_artifacts.language IS 'artifact language';
COMMENT ON COLUMN syft_repo_artifacts.cpes IS 'artifact cpes';
COMMENT ON COLUMN syft_repo_artifacts.purl IS 'artifact purl';
