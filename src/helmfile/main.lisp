(in-package #:hotel-foxtrot.helmfile)

(defun assoc-list-p (lst)
  (or (null lst)
      (and (consp lst)
           (every #'consp lst))))

(deftype assoc-list ()
  `(satisfies assoc-list-p))

(defparameter +helmfile-binary+ "/home/mike/.local/share/mise/installs/helmfile/latest/bin/helmfile")

(defun encode-helmfile-selector (selector)
  "Converts SELECTOR into valid format for a helmfile selector.

(enccode-helmfile-selector name=foo,chart=baz)
=> \"name=foo,chart=baz\"
(encode-helmfile-selector '((\"name\" . \"foo\") (\"chart\" . \"baz\")))
=> \"name=foo,chart=baz\""
  (serapeum:etypecase-of (or string assoc-list (satisfies hash-table-p)) selector
    ((string) selector)
    ((satisfies hash-table-p) (encode-helmfile-selector (alexandria:hash-table-alist selector)))
    ((assoc-list) (format nil "~{~A~^,~}"
                          (serapeum:collecting
                            (dolist (pair selector)
                              (collect (string-downcase (concatenate 'string (car pair) "=" (cdr pair))))))))))

(defun decode-helmfile-selector (selector)
  (mapcar (lambda (label)
            (let ((pair (uiop:split-string label :separator '(#\= #\:))))
              (cons (car pair)
                    (cadr pair))))
          (uiop:split-string selector :separator '(#\,))))

(defun decode-helmfile-labels (lbls)
  (decode-helmfile-selector lbls))

(defun helmfile-operation-p (in)
  (member in
          '("apply" "build" "cache" "deps"
            "destroy" "diff" "fetch" "init"
            "lint" "list" "repos" "show-tag"
            "status" "sync" "template" "write-values") :test #'equal))

(deftype helmfile-operation ()
  '(satisfies helmfile-operation-p))

(defun run-helmfile (environment operation &key skip-deps helmfile-path selector output)
  (let* ((validated-selector (encode-helmfile-selector selector))
         (command (remove-if #'alexandria:emptyp
                             (list +helmfile-binary+
                                   operation
                                   (format nil "--environment=~a" environment)
                                   (when selector (format nil "--selector=~a" validated-selector))
                                   (when helmfile-path (format nil "--file=~a" helmfile-path))
                                   (when output (format nil "--output=~a" output))
                                   (when skip-deps "--skip-deps")))))
    (log4cl-extras/context:with-fields (:command command
                                        :environment environment
                                        :operation operation
                                        :skip-deps skip-deps
                                        :helmfile-path helmfile-path
                                        :selector validated-selector
                                        :output output)
      (log:info "running helmfile command")
      (serapeum:mvlet ((output error status (uiop:run-program
                                             command
                                             :output '(:string :stripped t)
                                             :error-output '(:string :stripped t))))
        (cond
          ((> status 0) (error 'run-helmfile-error :output output :error-output error :status-code status :operation operation :environment environment :selector validated-selector))
          ((eql status 0) (values output error status)))))))

(serapeum.exporting:defun helmfile-apply (environment &key skip-deps helmfile-path selector)
  (parse-diff-output (run-helmfile environment "apply" :skip-deps skip-deps :helmfile-path helmfile-path :selector selector)))

(serapeum.exporting:defun helmfile-diff (environment &key skip-deps helmfile-path selector)
  (parse-diff-output (run-helmfile environment "diff" :skip-deps skip-deps :helmfile-path helmfile-path :selector selector)))

(defstruct helmfile-list-output
  (namespace "" :type string)
  (name "" :type string)
  (chart "" :type string)
  (version "" :type string)
  (labels nil :type assoc-list)
  installed
  enabled)

(serapeum.exporting:defun helmfile-list (environment &key skip-deps helmfile-path selector)
  (map 'list (lambda (helmfile-list-row)
               (serapeum:lret ((release (make-helmfile-list-output :labels nil)))
                 (serapeum:do-hash-table (key value helmfile-list-row)
                   (serapeum:string-ecase key
                     (("version") (setf (helmfile-list-output-version release) value))
                     (("chart") (setf (helmfile-list-output-chart release) value))
                     (("labels") (setf (helmfile-list-output-labels release ) (decode-helmfile-labels value)))
                     (("installed") (setf (helmfile-list-output-installed release) value))
                     (("enabled") (setf (helmfile-list-output-enabled release) value))
                     (("namespace") (setf (helmfile-list-output-namespace release) value))
                     (("name") (setf (helmfile-list-output-name release) value))))))
       (run-helmfile environment "list" :skip-deps skip-deps :helmfile-path helmfile-path :selector selector :output "json")))
