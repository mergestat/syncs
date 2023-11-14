CREATE TABLE IF NOT EXISTS github_pr_review_comments (
    repo_id uuid REFERENCES repos(id) ON DELETE CASCADE ON UPDATE RESTRICT,
    url text,
    pull_request_review_id bigint,
    pull_request_number integer,
    id bigint,
    diff_hunk text,
    path text,
    commit_id text,
    original_commit_id text,
    user_login text,
    user_id integer,
    user_avatar_url text,
    user_url text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    author_association text,
    body text,
    reactions jsonb,
    start_line integer,
    original_start_line integer,
    start_side text,
    line integer,
    original_line integer,
    side text,
    original_position integer,
    position integer,
    subject_type text,

    _mergestat_synced_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT github_pr_review_comments_pkey PRIMARY KEY (repo_id, id)

);

COMMENT ON TABLE github_pr_review_comments IS 'issue comments of a GitHub repo';
COMMENT ON COLUMN github_pr_review_comments.repo_id IS 'foreign key for public.repos.id';
COMMENT ON COLUMN github_pr_review_comments.url IS 'URL to the issue comment';
COMMENT ON COLUMN github_pr_review_comments.pull_request_review_id IS 'id of the pull request review';
COMMENT ON COLUMN github_pr_review_comments.pull_request_number IS 'pull request number';
COMMENT ON COLUMN github_pr_review_comments.id IS 'id of the review comment';
COMMENT ON COLUMN github_pr_review_comments.diff_hunk IS 'diff hunk';
COMMENT ON COLUMN github_pr_review_comments.path IS 'file path';
COMMENT ON COLUMN github_pr_review_comments.commit_id IS 'commit id';
COMMENT ON COLUMN github_pr_review_comments.original_commit_id IS 'original commit id';
COMMENT ON COLUMN github_pr_review_comments.user_login IS 'login of the user who created the review comment';
COMMENT ON COLUMN github_pr_review_comments.user_id IS 'id of the user who created the review comment';
COMMENT ON COLUMN github_pr_review_comments.user_avatar_url IS 'avatar URL of the user who created the review comment';
COMMENT ON COLUMN github_pr_review_comments.user_url IS 'URL to the user who created the review comment';
COMMENT ON COLUMN github_pr_review_comments.created_at IS 'timestamp when the review comment was created';
COMMENT ON COLUMN github_pr_review_comments.updated_at IS 'timestamp when the review comment was updated';
COMMENT ON COLUMN github_pr_review_comments.author_association IS 'author association of the user who created the review comment';
COMMENT ON COLUMN github_pr_review_comments.body IS 'body of the review comment';
COMMENT ON COLUMN github_pr_review_comments.reactions IS 'reactions of the review comment';
COMMENT ON COLUMN github_pr_review_comments.start_line IS 'start line';
COMMENT ON COLUMN github_pr_review_comments.original_start_line IS 'original start line';
COMMENT ON COLUMN github_pr_review_comments.start_side IS 'start side';
COMMENT ON COLUMN github_pr_review_comments.line IS 'line';
COMMENT ON COLUMN github_pr_review_comments.original_line IS 'original line';
COMMENT ON COLUMN github_pr_review_comments.side IS 'side';
COMMENT ON COLUMN github_pr_review_comments.original_position IS 'original position';
COMMENT ON COLUMN github_pr_review_comments.position IS 'position';
COMMENT ON COLUMN github_pr_review_comments.subject_type IS 'subject type';
COMMENT ON COLUMN github_pr_review_comments._mergestat_synced_at IS 'timestamp when record was synced into the MergeStat database';

CREATE INDEX IF NOT EXISTS idx_github_pr_review_comments_repo_id_fkey ON github_pr_review_comments(repo_id uuid_ops);
