CREATE TABLE IF NOT EXISTS github_stargazers (
    repo_id uuid REFERENCES repos(id) ON DELETE CASCADE ON UPDATE RESTRICT,
    login text,
    email text,
    name text,
    bio text,
    company text,
    avatar_url text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    twitter text,
    website text,
    location text,
    starred_at timestamp with time zone,
    _mergestat_synced_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT github_stargazers_pkey PRIMARY KEY (repo_id, login)
);
COMMENT ON TABLE github_stargazers IS 'stargazers of a GitHub repo';
COMMENT ON COLUMN github_stargazers.repo_id IS 'foreign key for public.repos.id';
COMMENT ON COLUMN github_stargazers.login IS 'login of the user who starred the repo';
COMMENT ON COLUMN github_stargazers.email IS 'email of the user who starred the repo';
COMMENT ON COLUMN github_stargazers.name IS 'name of the user who starred the repo';
COMMENT ON COLUMN github_stargazers.bio IS 'public profile bio of the user who starred the repo';
COMMENT ON COLUMN github_stargazers.company IS 'company of the user who starred the repo';
COMMENT ON COLUMN github_stargazers.avatar_url IS 'URL to the avatar of the user who starred the repo';
COMMENT ON COLUMN github_stargazers.created_at IS 'timestamp of when the user was created who starred the repo';
COMMENT ON COLUMN github_stargazers.updated_at IS 'timestamp of the latest update to the user who starred the repo';
COMMENT ON COLUMN github_stargazers.twitter IS 'twitter of the user who starred the repo';
COMMENT ON COLUMN github_stargazers.website IS 'website of the user who starred the repo';
COMMENT ON COLUMN github_stargazers.location IS 'location of the user who starred the repo';
COMMENT ON COLUMN github_stargazers.starred_at IS 'timestamp the user starred the repo';
COMMENT ON COLUMN github_stargazers._mergestat_synced_at IS 'timestamp when record was synced into the MergeStat database';

CREATE UNIQUE INDEX IF NOT EXISTS github_stargazers_pkey ON github_stargazers(repo_id uuid_ops,login text_ops);
CREATE INDEX IF NOT EXISTS idx_github_stargazers_repo_id_fkey ON github_stargazers(repo_id uuid_ops);
