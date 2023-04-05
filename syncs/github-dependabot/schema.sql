-- SQL migration to setup schema for github-dependabot syncer

CREATE TABLE IF NOT EXISTS public.github_repo_dependabot_alert_results (
    repo_id uuid REFERENCES public.repos(id) ON DELETE CASCADE ON UPDATE RESTRICT,
    dependabot_alerts jsonb,
    _mergestat_synced_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT github_repo_dependabot_alert_results_pkey PRIMARY KEY (repo_id)
);

COMMENT ON TABLE github_repo_dependabot_alert_results IS 'GitHub Dependabot alert results';
COMMENT ON COLUMN github_repo_dependabot_alert_results.repo_id IS 'foreign key for public.repos.id';
COMMENT ON COLUMN github_repo_dependabot_alert_results.dependabot_alerts IS 'JSON results of Dependabot alerts';
COMMENT ON COLUMN github_repo_dependabot_alert_results._mergestat_synced_at IS 'timestamp when record was synced into the MergeStat database';

CREATE UNIQUE INDEX IF NOT EXISTS github_repo_dependabot_alert_results_pkey ON github_repo_dependabot_alert_results(repo_id uuid_ops);
CREATE INDEX IF NOT EXISTS idx_github_repo_dependabot_alert_results_repo_id_fkey ON github_repo_dependabot_alert_results(repo_id uuid_ops);

DROP VIEW IF EXISTS public.github_repo_dependabot_alerts;
CREATE OR REPLACE VIEW public.github_repo_dependabot_alerts AS (
    SELECT
        github_repo_dependabot_alert_results.repo_id,
        a->>'number' AS number,
        a->>'state' AS state,
        a->'dependency'->'package'->>'ecosystem' AS dependency_package_ecosystem,
        a->'dependency'->'package'->>'name' AS dependency_package_name,
        a->'dependency'->>'manifest_path' AS manifest_path,
        a AS dependabot_alert,
        github_repo_dependabot_alert_results._mergestat_synced_at
    FROM github_repo_dependabot_alert_results,
    LATERAL jsonb_array_elements(github_repo_dependabot_alert_results.dependabot_alerts) a
)
