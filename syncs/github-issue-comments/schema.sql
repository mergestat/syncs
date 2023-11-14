CREATE TABLE IF NOT EXISTS github_issue_comments (
    repo_id uuid REFERENCES repos(id) ON DELETE CASCADE ON UPDATE RESTRICT,
    id bigint,
    issue_number integer,
    url text,
    user_login text,
    user_id integer,
    user_type text,
    user_avatar_url text,
    user_url text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    author_association text,
    body text,
    reactions jsonb,

    _mergestat_synced_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT github_issue_comments_pkey PRIMARY KEY (repo_id, id)

);

COMMENT ON TABLE github_issue_comments IS 'issue comments of a GitHub repo';
COMMENT ON COLUMN github_issue_comments.repo_id IS 'foreign key for public.repos.id';
COMMENT ON COLUMN github_issue_comments.id IS 'id of the issue comment';
COMMENT ON COLUMN github_issue_comments.issue_number IS 'issue number';
COMMENT ON COLUMN github_issue_comments.url IS 'URL to the issue comment';
COMMENT ON COLUMN github_issue_comments.user_login IS 'login of the user who created the issue comment';
COMMENT ON COLUMN github_issue_comments.user_id IS 'login of the user who created the issue comment';
COMMENT ON COLUMN github_issue_comments.user_type IS 'type of the user who created the issue comment';
COMMENT ON COLUMN github_issue_comments.user_avatar_url IS 'avatar url of the user who created the issue comment';
COMMENT ON COLUMN github_issue_comments.user_url IS 'url of the user who created the issue comment';
COMMENT ON COLUMN github_issue_comments.created_at IS 'timestamp of when the issue comment was created';
COMMENT ON COLUMN github_issue_comments.updated_at IS 'timestamp of when the issue comment was updated';
COMMENT ON COLUMN github_issue_comments.author_association IS 'author association of the user who created the issue comment';
COMMENT ON COLUMN github_issue_comments.body IS 'body of the issue comment';
COMMENT ON COLUMN github_issue_comments.reactions IS 'reactions on the issue comment';
COMMENT ON COLUMN github_issue_comments._mergestat_synced_at IS 'timestamp when record was synced into the MergeStat database';

CREATE INDEX IF NOT EXISTS idx_github_issue_comments_repo_id_fkey ON github_issue_comments(repo_id uuid_ops);
