CREATE TABLE IF NOT EXISTS github_issues (
    repo_id uuid REFERENCES repos(id) ON DELETE CASCADE ON UPDATE RESTRICT,
    author_login text,
    body text,
    closed boolean,
    closed_at timestamp with time zone,
    comment_count integer,
    created_at timestamp with time zone,
    created_via_email boolean,
    database_id integer,
    editor_login text,
    includes_created_edit boolean,
    label_count integer,
    last_edited_at timestamp with time zone,
    locked boolean,
    milestone_count integer,
    number integer NOT NULL,
    participant_count integer,
    published_at timestamp with time zone,
    reaction_count integer,
    state text,
    title text,
    updated_at timestamp with time zone,
    url text,
    labels jsonb NOT NULL DEFAULT jsonb_build_array(),
    _mergestat_synced_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT github_issues_pkey PRIMARY KEY (repo_id, database_id)
);

COMMENT ON TABLE github_issues IS 'issues of a GitHub repo';
COMMENT ON COLUMN github_issues.repo_id IS 'foreign key for public.repos.id';
COMMENT ON COLUMN github_issues.author_login IS 'login of the author of the issue';
COMMENT ON COLUMN github_issues.body IS 'body of the issue';
COMMENT ON COLUMN github_issues.closed IS 'boolean to determine if the issue is closed';
COMMENT ON COLUMN github_issues.closed_at IS 'timestamp of when the issue was closed';
COMMENT ON COLUMN github_issues.created_via_email IS 'boolean to determine if the issue was created via email';
COMMENT ON COLUMN github_issues.database_id IS 'GitHub database_id of the issue';
COMMENT ON COLUMN github_issues.editor_login IS 'login of the editor of the issue';
COMMENT ON COLUMN github_issues.includes_created_edit IS 'boolean to determine if the issue was edited and includes an edit with the creation data';
COMMENT ON COLUMN github_issues.label_count IS 'number of labels associated to the issue';
COMMENT ON COLUMN github_issues.last_edited_at IS 'timestamp when the issue was edited';
COMMENT ON COLUMN github_issues.locked IS 'boolean to determine if the issue is locked';
COMMENT ON COLUMN github_issues.milestone_count IS 'number of milestones associated to the issue';
COMMENT ON COLUMN github_issues.number IS 'GitHub number for the issue';
COMMENT ON COLUMN github_issues.participant_count IS 'number of participants associated to the issue';
COMMENT ON COLUMN github_issues.published_at IS 'timestamp when the issue was published';
COMMENT ON COLUMN github_issues.reaction_count IS 'number of reactions associated to the issue';
COMMENT ON COLUMN github_issues.state IS 'state of the issue';
COMMENT ON COLUMN github_issues.title IS 'title of the issue';
COMMENT ON COLUMN github_issues.updated_at IS 'timestamp when the issue was updated';
COMMENT ON COLUMN github_issues.url IS 'GitHub URL of the issue';
COMMENT ON COLUMN github_issues.labels IS 'labels associated to the issue';
COMMENT ON COLUMN github_issues._mergestat_synced_at IS 'timestamp when record was synced into the MergeStat database';

CREATE UNIQUE INDEX IF NOT EXISTS github_issues_pkey ON github_issues(repo_id uuid_ops,database_id int4_ops);
CREATE INDEX IF NOT EXISTS idx_github_issues_created_at_closed_at_database_id ON github_issues(created_at timestamptz_ops DESC,closed_at timestamptz_ops DESC,database_id int4_ops);
CREATE INDEX IF NOT EXISTS idx_github_issues_repo_id_fkey ON github_issues(repo_id uuid_ops);
