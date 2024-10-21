-- migrate:up

CREATE TABLE IF NOT EXISTS helmfile_diffs (
    id SERIAL PRIMARY KEY,
    namespace VARCHAR(255) NOT NULL,
    release VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (namespace, release)
);

-- migrate:down

DROP TABLE helmfile_diffs;
