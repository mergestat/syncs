-- SQL migration to setup schema for git-pull-requests syncer

CREATE TABLE IF NOT EXISTS public.github_pull_requests (
    repo_id uuid REFERENCES public.repos(id) ON DELETE CASCADE ON UPDATE RESTRICT,
    additions integer,
    author_login text,
    author_association text,
    author_avatar_url text,
    author_name text,
    base_ref_oid text,
    base_ref_name text,
    base_repository_name text,
    body text,
    changed_files integer,
    closed boolean,
    closed_at timestamp with time zone,
    comment_count integer,
    commit_count integer,
    created_at timestamp with time zone,
    created_via_email boolean,
    database_id bigint,
    deletions integer,
    editor_login text,
    head_ref_name text,
    head_ref_oid text,
    head_repository_name text,
    is_draft boolean,
    label_count integer,
    last_edited_at timestamp with time zone,
    locked boolean,
    maintainer_can_modify boolean,
    mergeable text,
    merged boolean,
    merged_at timestamp with time zone,
    merged_by text,
    number integer,
    participant_count integer,
    published_at timestamp with time zone,
    review_decision text,
    state text,
    title text,
    updated_at timestamp with time zone,
    url text,
    labels jsonb NOT NULL DEFAULT jsonb_build_array(),
    _mergestat_synced_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT github_pull_requests_pkey PRIMARY KEY (repo_id, database_id)
);

COMMENT ON TABLE github_pull_requests IS 'GitHub Workflow Run Jobs';
COMMENT ON COLUMN github_pull_requests.repo_id IS 'foreign key for public.repos.id';
COMMENT ON COLUMN github_pull_requests.additions IS 'the number of additions in the pull request';
COMMENT ON COLUMN github_pull_requests.author_login IS 'login of the author of the pull request';
COMMENT ON COLUMN github_pull_requests.author_association IS 'author association to the repo';
COMMENT ON COLUMN github_pull_requests.author_avatar_url IS 'URL to the avatar of the author of the pull request';
COMMENT ON COLUMN github_pull_requests.author_name IS 'name of the author of the pull request';
COMMENT ON COLUMN github_pull_requests.base_ref_oid IS 'the base ref object id associated with the pull request';
COMMENT ON COLUMN github_pull_requests.base_ref_name IS 'the name of base ref associated with the pull request';
COMMENT ON COLUMN github_pull_requests.base_repository_name IS 'the name of the base repo for the pull request';
COMMENT ON COLUMN github_pull_requests.body IS 'body of the pull request';
COMMENT ON COLUMN github_pull_requests.changed_files IS 'the number of files changed/modified in the pull request';
COMMENT ON COLUMN github_pull_requests.closed IS 'boolean to determine if the pull request is closed';
COMMENT ON COLUMN github_pull_requests.closed_at IS 'timestamp of when the pull request was closed';
COMMENT ON COLUMN github_pull_requests.comment_count IS 'the number of comments in the pull request';
COMMENT ON COLUMN github_pull_requests.created_at IS 'timestamp of when the pull request was created';
COMMENT ON COLUMN github_pull_requests.created_via_email IS 'boolean to determine if the pull request was created via email';
COMMENT ON COLUMN github_pull_requests.database_id IS 'GitHub database_id of the pull request';
COMMENT ON COLUMN github_pull_requests.deletions IS 'the number of deletions in the pull request';
COMMENT ON COLUMN github_pull_requests.editor_login IS 'login of the editor of the pull request';
COMMENT ON COLUMN github_pull_requests.head_ref_name IS 'the name of head ref associated with the pull request';
COMMENT ON COLUMN github_pull_requests.head_ref_oid IS 'the head ref object id associated with the pull request';
COMMENT ON COLUMN github_pull_requests.head_repository_name IS 'the name of the head repo for the pull request';
COMMENT ON COLUMN github_pull_requests.is_draft IS 'boolean to determine if the pull request is a draft';
COMMENT ON COLUMN github_pull_requests.label_count IS 'number of labels associated to the pull request';
COMMENT ON COLUMN github_pull_requests.last_edited_at IS 'timestamp of when the pull request was last edited';
COMMENT ON COLUMN github_pull_requests.locked IS 'boolean to determine if the pull request is locked';
COMMENT ON COLUMN github_pull_requests.maintainer_can_modify IS 'boolean to determine if a maintainer can modify the pull request';
COMMENT ON COLUMN github_pull_requests.mergeable IS 'mergeable state of the pull request';
COMMENT ON COLUMN github_pull_requests.merged IS 'boolean to determine if the pull request is merged';
COMMENT ON COLUMN github_pull_requests.merged_at IS 'timestamp of when the pull request was merged';
COMMENT ON COLUMN github_pull_requests.merged_by IS 'actor who merged the pull request';
COMMENT ON COLUMN github_pull_requests.number IS 'GitHub number of the pull request';
COMMENT ON COLUMN github_pull_requests.participant_count IS 'number of participants associated to the pull request';
COMMENT ON COLUMN github_pull_requests.published_at IS 'timestamp of when the pull request was published';
COMMENT ON COLUMN github_pull_requests.review_decision IS 'review decision of the pull request';
COMMENT ON COLUMN github_pull_requests.state IS 'state of the pull request';
COMMENT ON COLUMN github_pull_requests.title IS 'title of the pull request';
COMMENT ON COLUMN github_pull_requests.updated_at IS 'timestamp of when the pull request was updated';
COMMENT ON COLUMN github_pull_requests.url IS 'GitHub URL of the pull request';
COMMENT ON COLUMN github_pull_requests.labels IS 'labels associated to the pull request';
COMMENT ON COLUMN github_pull_requests._mergestat_synced_at IS 'timestamp when record was synced into the MergeStat database';

CREATE UNIQUE INDEX IF NOT EXISTS github_pull_requests_pkey ON github_pull_requests(repo_id uuid_ops,database_id int8_ops);
CREATE INDEX IF NOT EXISTS idx_github_pull_requests_repo_id_fkey ON github_pull_requests(repo_id uuid_ops);
