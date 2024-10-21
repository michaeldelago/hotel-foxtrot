-- migrate:up transaction:false

CREATE INDEX CONCURRENTLY IF NOT EXISTS helmfile_diffs_namespace_release_index ON helmfile_diffs (namespace, release);

-- migrate:down

DROP INDEX helmfile_diffs_namespace_release_index;
