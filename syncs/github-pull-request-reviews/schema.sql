-- SQL migration to setup schema for github-pull-request-reviews

CREATE TABLE IF NOT EXISTS github_pull_request_reviews (
    repo_id uuid REFERENCES repos(id) ON DELETE CASCADE ON UPDATE RESTRICT,
    pr_number integer NOT NULL,
    id text,
    author_login text,
    author_url text,
    author_association text,
    author_can_push_to_repository boolean,
    body text,
    comment_count integer,
    created_at timestamp with time zone,
    created_via_email boolean,
    editor_login text,
    last_edited_at timestamp with time zone,
    published_at timestamp with time zone,
    state text,
    submitted_at timestamp with time zone,
    updated_at timestamp with time zone,
    _mergestat_synced_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT github_pull_request_reviews_pkey PRIMARY KEY (repo_id, id)
);

COMMENT ON TABLE github_pull_request_reviews IS 'reviews for all pull requests of a GitHub repo';
COMMENT ON COLUMN github_pull_request_reviews.repo_id IS 'foreign key for public.repos.id';
COMMENT ON COLUMN github_pull_request_reviews.pr_number IS 'GitHub pull request number of the review';
COMMENT ON COLUMN github_pull_request_reviews.id IS 'GitHub id of the review';
COMMENT ON COLUMN github_pull_request_reviews.author_login IS 'login of the author of the review';
COMMENT ON COLUMN github_pull_request_reviews.author_url IS 'URL to the profile of the author of the review';
COMMENT ON COLUMN github_pull_request_reviews.author_association IS 'author association to the repo';
COMMENT ON COLUMN github_pull_request_reviews.author_can_push_to_repository IS 'boolean to determine if author can push to the repo';
COMMENT ON COLUMN github_pull_request_reviews.body IS 'body of the review';
COMMENT ON COLUMN github_pull_request_reviews.comment_count IS 'number of comments associated to the review';
COMMENT ON COLUMN github_pull_request_reviews.created_at IS 'timestamp of when the review was created';
COMMENT ON COLUMN github_pull_request_reviews.created_via_email IS 'boolean to determine if the review was created via email';
COMMENT ON COLUMN github_pull_request_reviews.editor_login IS 'login of the editor of the review';
COMMENT ON COLUMN github_pull_request_reviews.last_edited_at IS 'timestamp of when the review was last edited';
COMMENT ON COLUMN github_pull_request_reviews.published_at IS 'timestamp of when the review was published';
COMMENT ON COLUMN github_pull_request_reviews.state IS 'state of the review';
COMMENT ON COLUMN github_pull_request_reviews.submitted_at IS 'timestamp of when the review was submitted';
COMMENT ON COLUMN github_pull_request_reviews.updated_at IS 'timestamp of when the review was updated';
COMMENT ON COLUMN github_pull_request_reviews._mergestat_synced_at IS 'timestamp when record was synced into the MergeStat database';

CREATE INDEX IF NOT EXISTS idx_reviews_repo_id_fkey ON github_pull_request_reviews(repo_id uuid_ops);
CREATE UNIQUE INDEX IF NOT EXISTS github_pull_request_reviews_pkey ON github_pull_request_reviews(repo_id uuid_ops,id text_ops);
