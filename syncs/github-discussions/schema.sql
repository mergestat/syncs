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
    body text,
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
-- TODO(patrickdevivo) describe other columns

CREATE INDEX IF NOT EXISTS idx_github_discussions_repo_id_fkey ON github_discussions(repo_id uuid_ops);

CREATE TABLE IF NOT EXISTS github_discussion_categories (
    repo_id uuid REFERENCES repos(id) ON DELETE CASCADE ON UPDATE RESTRICT,
    id text,
    name text,
    description text,
    created_at timestamp with time zone,
    emoji text,
    is_answerable boolean,
    slug text,
    updated_at timestamp with time zone,

    _mergestat_synced_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT github_discussion_categories_pkey PRIMARY KEY (repo_id, id)
);

CREATE INDEX IF NOT EXISTS idx_github_discussion_categories_repo_id_fkey ON github_discussions(repo_id uuid_ops);

CREATE TABLE IF NOT EXISTS github_discussion_comments (
    repo_id uuid REFERENCES repos(id) ON DELETE CASCADE ON UPDATE RESTRICT,
    id text,
    discussion_id text,
    author_login text,
    author_association text,
    body text,
    created_at timestamp with time zone,
    deleted_at timestamp with time zone,
    is_minimized boolean,
    minimized_reason text,
    reaction_count int,
    reply_to_id text,
    updated_at timestamp with time zone,
    upvote_count int,
    url text,

    _mergestat_synced_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT github_discussion_commentss_pkey PRIMARY KEY (repo_id, id)
);
