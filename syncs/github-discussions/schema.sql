CREATE TABLE IF NOT EXISTS github_discussions (
    repo_id uuid REFERENCES repos(id) ON DELETE CASCADE ON UPDATE RESTRICT,
    id text,
    active_lock_reason text,
    is_answered boolean,
    answer_id text,
    answer_chosen_at timestamp with time zone,
    answer_chosen_by text,
    author_login text,
    author_association text,
    body_text text,
    category text,
    comment_count int,
    created_at timestamp with time zone,
    created_via_email boolean,
    database_id bigint,
    editor_login text,
    last_edited_at timestamp with time zone,
    locked boolean,
    number int,
    published_at timestamp with time zone,
    reaction_count int,
    title text,
    updated_at timestamp with time zone,
    url text,

    _mergestat_synced_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT github_discussions_pkey PRIMARY KEY (repo_id, database_id)
);

COMMENT ON TABLE github_discussions IS 'discussions of a GitHub repo';
COMMENT ON COLUMN github_discussions.repo_id IS 'foreign key for public.repos.id';
-- COMMENT ON COLUMN github_issues.author_login IS 'login of the author of the issue';
-- COMMENT ON COLUMN github_issues.body IS 'body of the issue';
-- COMMENT ON COLUMN github_issues.closed IS 'boolean to determine if the issue is closed';
-- COMMENT ON COLUMN github_issues.closed_at IS 'timestamp of when the issue was closed';
-- COMMENT ON COLUMN github_issues.created_via_email IS 'boolean to determine if the issue was created via email';
-- COMMENT ON COLUMN github_issues.database_id IS 'GitHub database_id of the issue';
-- COMMENT ON COLUMN github_issues.editor_login IS 'login of the editor of the issue';
-- COMMENT ON COLUMN github_issues.includes_created_edit IS 'boolean to determine if the issue was edited and includes an edit with the creation data';
-- COMMENT ON COLUMN github_issues.label_count IS 'number of labels associated to the issue';
-- COMMENT ON COLUMN github_issues.last_edited_at IS 'timestamp when the issue was edited';
-- COMMENT ON COLUMN github_issues.locked IS 'boolean to determine if the issue is locked';
-- COMMENT ON COLUMN github_issues.milestone_count IS 'number of milestones associated to the issue';
-- COMMENT ON COLUMN github_issues.number IS 'GitHub number for the issue';
-- COMMENT ON COLUMN github_issues.participant_count IS 'number of participants associated to the issue';
-- COMMENT ON COLUMN github_issues.published_at IS 'timestamp when the issue was published';
-- COMMENT ON COLUMN github_issues.reaction_count IS 'number of reactions associated to the issue';
-- COMMENT ON COLUMN github_issues.state IS 'state of the issue';
-- COMMENT ON COLUMN github_issues.title IS 'title of the issue';
-- COMMENT ON COLUMN github_issues.updated_at IS 'timestamp when the issue was updated';
-- COMMENT ON COLUMN github_issues.url IS 'GitHub URL of the issue';
-- COMMENT ON COLUMN github_issues.labels IS 'labels associated to the issue';
-- COMMENT ON COLUMN github_issues._mergestat_synced_at IS 'timestamp when record was synced into the MergeStat database';

CREATE INDEX IF NOT EXISTS idx_github_discussions_repo_id_fkey ON github_discussions(repo_id uuid_ops);

-- ----
-- CREATE TABLE IF NOT EXISTS github_discussion_comments (
--     repo_id uuid REFERENCES repos(id) ON DELETE CASCADE ON UPDATE RESTRICT,

--     _mergestat_synced_at timestamp with time zone NOT NULL DEFAULT now(),
--     CONSTRAINT github_discussion_comments_pkey PRIMARY KEY (repo_id, database_id)
-- );

-- COMMENT ON TABLE github_discussion_comments IS 'discussion comments of a GitHub repo';
-- COMMENT ON COLUMN github_discussion_comments.repo_id IS 'foreign key for public.repos.id';