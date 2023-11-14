-- SQL migration to setup schema for github-releases syncer

CREATE TABLE IF NOT EXISTS public.github_releases (
    repo_id uuid REFERENCES public.repos(id) ON DELETE CASCADE ON UPDATE RESTRICT,
    url text,
    assets_url text,
    upload_url text,
    html_url text,
    database_id integer,
    author_login text,
    author_url text,
    author_avatar_url text,
    tag_name text,
    target_commitish text,
    name text,
    draft boolean,
    prerelease boolean,
    created_at timestamp with time zone,
    published_at timestamp with time zone,
    assets jsonb DEFAULT jsonb_build_array(),
    tarball_url text,
    zipball_url text,
    body text,
    mentions_count integer,
    _mergestat_synced_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT github_releases_pkey PRIMARY KEY (repo_id, database_id)
);

COMMENT ON TABLE github_releases IS 'GitHub Repo Releases';
COMMENT ON COLUMN github_releases.repo_id IS 'foreign key for public.repos.id';
COMMENT ON COLUMN github_releases.url IS 'GitHub URL of the release';
COMMENT ON COLUMN github_releases.assets_url IS 'GitHub URL of the release assets';
COMMENT ON COLUMN github_releases.upload_url IS 'GitHub URL of the release uploads';
COMMENT ON COLUMN github_releases.html_url IS 'HTML URL of the GitHub release';
COMMENT ON COLUMN github_releases.database_id IS 'GitHub database_id of the release';
COMMENT ON COLUMN github_releases.author_login IS 'login of the author of the release';
COMMENT ON COLUMN github_releases.author_url IS 'URL to the profile of the author of the release';
COMMENT ON COLUMN github_releases.author_avatar_url IS 'URL to the avatar of the author of the release';
COMMENT ON COLUMN github_releases.tag_name IS 'tag name of the release';
COMMENT ON COLUMN github_releases.target_commitish IS 'specifies the commitish value that determines where the release is created from';
COMMENT ON COLUMN github_releases.name IS 'name of the release';
COMMENT ON COLUMN github_releases.draft IS 'boolean to identify the release as a draft (unpublished)';
COMMENT ON COLUMN github_releases.prerelease IS 'boolean to identify the release as a prerelease';
COMMENT ON COLUMN github_releases.created_at IS 'timestamp of when the release was created';
COMMENT ON COLUMN github_releases.published_at IS 'timestamp of when the release was published';
COMMENT ON COLUMN github_releases.assets IS 'assets associated with the release';
COMMENT ON COLUMN github_releases.tarball_url IS 'GitHub URL of the release tarball';
COMMENT ON COLUMN github_releases.zipball_url IS 'GitHub URL of the release zipball';
COMMENT ON COLUMN github_releases.body IS 'body of the release';
COMMENT ON COLUMN github_releases.mentions_count IS 'the number of mentions in the release';
COMMENT ON COLUMN github_releases._mergestat_synced_at IS 'timestamp when record was synced into the MergeStat database';

CREATE INDEX IF NOT EXISTS idx_github_releases_repo_id_fkey ON github_releases(repo_id uuid_ops);
