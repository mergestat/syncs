-- SQL migration to setup schema for git-refs syncer

CREATE TABLE IF NOT EXISTS public.git_refs (
  repo_id uuid REFERENCES public.repos(id) ON DELETE CASCADE ON UPDATE RESTRICT,
  full_name text,
  hash text,
  name text,
  remote text,
  target text,
  type text,
  tag_commit_hash text,
  _mergestat_synced_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT git_refs_pkey PRIMARY KEY (repo_id, full_name)
);

-- Human-friendly descriptions ----------------------------
COMMENT ON TABLE git_refs IS 'git refs of a repo';
COMMENT ON COLUMN git_refs.repo_id IS 'foreign key for public.repos.id';
COMMENT ON COLUMN git_refs.hash IS 'hash of the commit for refs that are not of type tag';
COMMENT ON COLUMN git_refs.name IS 'name of the ref';
COMMENT ON COLUMN git_refs.remote IS 'remote of the ref';
COMMENT ON COLUMN git_refs.target IS 'target of the ref';
COMMENT ON COLUMN git_refs.type IS 'type of the ref';
COMMENT ON COLUMN git_refs.tag_commit_hash IS 'hash of the commit for refs that are of type tag';
COMMENT ON COLUMN git_refs._mergestat_synced_at IS 'timestamp when record was synced into the MergeStat database';

-- Indices ------------------------------------------------
CREATE UNIQUE INDEX IF NOT EXISTS git_refs_pkey ON git_refs(repo_id uuid_ops,full_name text_ops);
CREATE INDEX IF NOT EXISTS idx_refs_repo_id_fkey ON git_refs(repo_id uuid_ops);
