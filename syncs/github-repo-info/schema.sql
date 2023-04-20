CREATE TABLE IF NOT EXISTS github_repo_info (
    repo_id uuid PRIMARY KEY REFERENCES repos(id) ON DELETE CASCADE ON UPDATE RESTRICT,
    owner text NOT NULL,
    name text NOT NULL,
    created_at timestamp with time zone,
    default_branch_name text,
    description text,
    size integer,
    fork_count integer,
    homepage_url text,
    is_archived boolean,
    is_disabled boolean,
    is_private boolean,
    total_issues_count integer,
    latest_release_author text,
    latest_release_created_at timestamp with time zone,
    latest_release_name text,
    latest_release_published_at timestamp with time zone,
    license_key text,
    license_name text,
    primary_language text,
    pushed_at timestamp with time zone,
    releases_count integer,
    stargazers_count integer,
    updated_at timestamp with time zone,
    watchers_count integer,
    _mergestat_synced_at timestamp with time zone NOT NULL DEFAULT now(),
    advanced_security text,
    secret_scanning text,
    secret_scanning_push_protection text,
    mirror_url text,
    CONSTRAINT github_repo_info_owner_name_key UNIQUE (owner, name)
);
COMMENT ON TABLE github_repo_info IS 'info/metadata of a GitHub repo';
COMMENT ON COLUMN github_repo_info.repo_id IS 'foreign key for public.repos.id';
COMMENT ON COLUMN github_repo_info.owner IS 'the user or organization that owns the repo';
COMMENT ON COLUMN github_repo_info.name IS 'the name of the repo';
COMMENT ON COLUMN github_repo_info.created_at IS 'timestamp of when the repo was created';
COMMENT ON COLUMN github_repo_info.default_branch_name IS 'the name of the default branch for the repo';
COMMENT ON COLUMN github_repo_info.description IS 'the description for the repo';
COMMENT ON COLUMN github_repo_info.size IS 'the number of kilobytes on disk for the repo';
COMMENT ON COLUMN github_repo_info.fork_count IS 'number of forks associated to the repo';
COMMENT ON COLUMN github_repo_info.homepage_url IS 'the GitHub homepage URL for the repo';
COMMENT ON COLUMN github_repo_info.is_archived IS 'boolean to determine if the repo is archived';
COMMENT ON COLUMN github_repo_info.is_disabled IS 'boolean to determine if the repo is disabled';
COMMENT ON COLUMN github_repo_info.is_private IS 'boolean to determine if the repo is private';
COMMENT ON COLUMN github_repo_info.total_issues_count IS 'number of issues associated to the repo';
COMMENT ON COLUMN github_repo_info.latest_release_author IS 'the author of the latest release in the repo';
COMMENT ON COLUMN github_repo_info.latest_release_created_at IS 'timestamp of the creation of the latest release in the repo';
COMMENT ON COLUMN github_repo_info.latest_release_name IS 'the name of the latest release in the repo';
COMMENT ON COLUMN github_repo_info.latest_release_published_at IS 'timestamp of the publishing of the latest release in the repo';
COMMENT ON COLUMN github_repo_info.license_key IS 'the license key for the repo';
COMMENT ON COLUMN github_repo_info.license_name IS 'the license name for the repo';
COMMENT ON COLUMN github_repo_info.primary_language IS 'the primary language for the repo';
COMMENT ON COLUMN github_repo_info.pushed_at IS 'timestamp of the latest push to the repo';
COMMENT ON COLUMN github_repo_info.releases_count IS 'number of releases associated to the repo';
COMMENT ON COLUMN github_repo_info.stargazers_count IS 'number of stargazers associated to the repo';
COMMENT ON COLUMN github_repo_info.updated_at IS 'timestamp of the latest update to the repo';
COMMENT ON COLUMN github_repo_info.watchers_count IS 'number of watchers associated to the repo';
COMMENT ON COLUMN github_repo_info._mergestat_synced_at IS 'timestamp when record was synced into the MergeStat database';
COMMENT ON COLUMN github_repo_info.advanced_security IS 'advanced security availability';
COMMENT ON COLUMN github_repo_info.secret_scanning IS 'secret scanning availability';
COMMENT ON COLUMN github_repo_info.secret_scanning_push_protection IS 'secret scanning push protection availability';

CREATE UNIQUE INDEX IF NOT EXISTS github_repo_info_owner_name_key ON github_repo_info(owner text_ops,name text_ops);
CREATE UNIQUE INDEX IF NOT EXISTS github_repo_info_pkey ON github_repo_info(repo_id uuid_ops);
CREATE INDEX IF NOT EXISTS idx_github_repo_info_repo_id_fkey ON github_repo_info(repo_id uuid_ops);
