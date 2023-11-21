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
    category_id text,
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
COMMENT ON COLUMN github_discussions.id IS 'id of the discussion';
COMMENT ON COLUMN github_discussions.active_lock_reason IS 'reason discussion is locked if locked is true';
COMMENT ON COLUMN github_discussions.is_answered IS 'if discussion has an accepted answer';
COMMENT ON COLUMN github_discussions.answer_id IS 'id of accepted answer if is_answered is true';
COMMENT ON COLUMN github_discussions.answer_chosen_at IS 'timestamp when answer was accepted if is_answered is true';
COMMENT ON COLUMN github_discussions.answer_chosen_by IS 'login of user who accepted answer if is_answered is true';
COMMENT ON COLUMN github_discussions.author_login IS 'login of discussion author';
COMMENT ON COLUMN github_discussions.author_association IS 'if author is a member, contributor or none';
COMMENT ON COLUMN github_discussions.body IS 'body text of discussion';
COMMENT ON COLUMN github_discussions.category_id IS 'foreign key for public.github_discussion_categories.id';
COMMENT ON COLUMN github_discussions.comment_count IS 'number of comments on discussion';
COMMENT ON COLUMN github_discussions.created_at IS 'timestamp when discussion was created';
COMMENT ON COLUMN github_discussions.created_via_email IS 'if discussion was created via email';
COMMENT ON COLUMN github_discussions.database_id IS 'database id of discussion, used in composite primary key';
COMMENT ON COLUMN github_discussions.editor_login IS 'login of last user to edit discussion';
COMMENT ON COLUMN github_discussions.last_edited_at IS 'timestamp of last edit to discussion';
COMMENT ON COLUMN github_discussions.locked IS 'if discussion is locked from further updates';
COMMENT ON COLUMN github_discussions.number IS 'number of discussion';
COMMENT ON COLUMN github_discussions.published_at IS 'timestamp when discussion was published';
COMMENT ON COLUMN github_discussions.reaction_count IS 'number of reactions on discussion';
COMMENT ON COLUMN github_discussions.title IS 'title of discussion';
COMMENT ON COLUMN github_discussions.updated_at IS 'timestamp when discussion was last updated';
COMMENT ON COLUMN github_discussions.url IS 'URL of discussion on GitHub';
COMMENT ON COLUMN github_discussions._mergestat_synced_at IS 'timestamp when record was synced into the MergeStat database';

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

COMMENT ON TABLE github_discussion_categories IS 'discussion categories of a GitHub repo';
COMMENT ON COLUMN github_discussion_categories.repo_id IS 'foreign key for public.repos.id';
COMMENT ON COLUMN github_discussion_categories.id IS 'id of the category';
COMMENT ON COLUMN github_discussion_categories.name IS 'name of the category';
COMMENT ON COLUMN github_discussion_categories.description IS 'description of the category';
COMMENT ON COLUMN github_discussion_categories.created_at IS 'timestamp when category was created';
COMMENT ON COLUMN github_discussion_categories.emoji IS 'emoji associated with category';
COMMENT ON COLUMN github_discussion_categories.is_answerable IS 'if discussions in category can be answered';
COMMENT ON COLUMN github_discussion_categories.slug IS 'slug for category page';
COMMENT ON COLUMN github_discussion_categories.updated_at IS 'timestamp when category was last updated';
COMMENT ON COLUMN github_discussion_categories._mergestat_synced_at IS 'timestamp when record was synced into the MergeStat database';

CREATE INDEX IF NOT EXISTS idx_github_discussion_categories_repo_id_fkey ON github_discussion_categories(repo_id uuid_ops);

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

COMMENT ON TABLE github_discussion_comments IS 'discussion comments of a GitHub repo';
COMMENT ON COLUMN github_discussion_comments.repo_id IS 'foreign key for public.repos.id';
COMMENT ON COLUMN github_discussion_comments.id IS 'id of the comment';
COMMENT ON COLUMN github_discussion_comments.discussion_id IS 'foreign key for github_discussions.id';
COMMENT ON COLUMN github_discussion_comments.author_login IS 'login of comment author';
COMMENT ON COLUMN github_discussion_comments.author_association IS 'if author is a member, contributor or none';
COMMENT ON COLUMN github_discussion_comments.body IS 'body text of comment';
COMMENT ON COLUMN github_discussion_comments.created_at IS 'timestamp when comment was created';
COMMENT ON COLUMN github_discussion_comments.deleted_at IS 'timestamp when comment was deleted if deleted';
COMMENT ON COLUMN github_discussion_comments.is_minimized IS 'if comment is minimized';
COMMENT ON COLUMN github_discussion_comments.minimized_reason IS 'reason comment is minimized if minimized';
COMMENT ON COLUMN github_discussion_comments.reaction_count IS 'number of reactions on comment';
COMMENT ON COLUMN github_discussion_comments.reply_to_id IS 'id of parent comment if reply';
COMMENT ON COLUMN github_discussion_comments.updated_at IS 'timestamp when comment was last updated';
COMMENT ON COLUMN github_discussion_comments.upvote_count IS 'number of upvotes on comment';
COMMENT ON COLUMN github_discussion_comments.url IS 'URL of comment on GitHub';
COMMENT ON COLUMN github_discussion_comments._mergestat_synced_at IS 'timestamp when record was synced into the MergeStat database';

CREATE INDEX IF NOT EXISTS idx_github_discussion_comments_repo_id_fkey ON github_discussion_comments(repo_id uuid_ops);
