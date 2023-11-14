CREATE TABLE IF NOT EXISTS github_issue_events (
    repo_id uuid REFERENCES repos(id) ON DELETE CASCADE ON UPDATE RESTRICT,
    id bigint,
    issue_number integer,
    url text,
    actor_login text,
    actor_id integer,
    actor_avatar_url text,
    actor_url text,
    event text,
    commit_id text,
    commit_url text,
    created_at timestamp with time zone,

    _mergestat_synced_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT github_issue_events_pkey PRIMARY KEY (repo_id, id)

);

COMMENT ON TABLE github_issue_events IS 'issue events of a GitHub repo';
COMMENT ON COLUMN github_issue_events.repo_id IS 'foreign key for public.repos.id';
COMMENT ON COLUMN github_issue_events.id IS 'id of the issue event';
COMMENT ON COLUMN github_issue_events.issue_number IS 'issue number';
COMMENT ON COLUMN github_issue_events.url IS 'URL to the issue event';
COMMENT ON COLUMN github_issue_events.actor_login IS 'login of the issue event actor';
COMMENT ON COLUMN github_issue_events.actor_id IS 'id of the issue event actor';
COMMENT ON COLUMN github_issue_events.actor_avatar_url IS 'URL to the issue event actor avatar';
COMMENT ON COLUMN github_issue_events.actor_url IS 'URL to the issue event actor';
COMMENT ON COLUMN github_issue_events.event IS 'event text';
COMMENT ON COLUMN github_issue_events.commit_id IS 'commit id';
COMMENT ON COLUMN github_issue_events.commit_url IS 'commit url';
COMMENT ON COLUMN github_issue_events.created_at IS 'timestamp of when the issue event was created';
COMMENT ON COLUMN github_issue_events._mergestat_synced_at IS 'timestamp when record was synced into the MergeStat database';

CREATE INDEX IF NOT EXISTS idx_github_issue_events_repo_id_fkey ON github_issue_events(repo_id uuid_ops);
