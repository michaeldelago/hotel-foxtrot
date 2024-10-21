-- name: get-diff-for-service
-- Retrieves diffs for a given :NAMESPACE and :RELEASE
SELECT *
FROM helmfile_diffs
WHERE namespace = :namespace
AND release = :release;


-- name: insert-new-service
-- Insert a new service into the database
INSERT INTO helmfile_diffs (namespace,release,content) VALUES (?,?,?) RETURNING id;
