(in-package :hotel-foxtrot/tests/main/helmfile)

(test parses-diffs-properly
  (is (hotel-foxtrot.helmfile::helmfile-diff-output-new-release
       (car (hotel-foxtrot.helmfile:parse-diff-output (uiop:read-file-string "tests/helmfile/fresh-install.yaml.diff"))))))
