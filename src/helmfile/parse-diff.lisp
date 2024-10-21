(in-package :hotel-foxtrot.helmfile)

;; parse the output of helm-diff (https://github.com/databus23/helm-diff). It has options to output as json, but unfortunately that doesn't include the actual changes being introduced.

(defun helmfile-change-type-p (in)
  (member in '("ADD" "MODIFY" "REMOVE") :test #'equal))

(deftype helmfile-change-type ()
  '(satisfies helmfile-change-type-p))

(defstruct helmfile-change
  (name "" :type string)
  (namespace "" :type string)
  (change-type nil :type helmfile-change-type)
  (api "" :type string)
  (kind "" :type string)
  (lines (list) :type list))

(defun change-reverse-lines (change)
  (let ((reversed (nreverse (helmfile-change-lines change))))
    (setf (helmfile-change-lines change) reversed)))

(defun list-of-helmfile-change-p (lst)
  (or (alexandria:emptyp lst)
      (and (consp lst)
           (every #'helmfile-change-p lst))))

(deftype list-of-helmfile-change ()
  '(satisfies list-of-helmfile-change-p))

(defstruct helmfile-diff-output
  (release "" :type string)
  (namespace "" :type string)
  (chart "" :type string)
  (changes (list) :type list-of-helmfile-change)
  (new-release nil))

(serapeum.exporting:defun parse-diff-output (raw)
  (labels ((get-change-type (l)
             (cond
               ((serapeum:string$= "has been added:" l) "ADD")
               ((serapeum:string$= "has changed:" l) "MODIFY")
               ((serapeum:string$= "has been removed:" l) "REMOVE")
               (t nil)))
           (new-change-p (l)
             (get-change-type l))
           (new-release-p (l)
             (= 0 (or (serapeum:string*= "Comparing release=" l) 1)))
           (comment-line-p (l)
             (= 0 (or (serapeum:string*= "#" l) 1)))
           (change-from-line (l)
             (destructuring-bind (namespace resource-name kind api &rest rest)
                 (remove-if #'alexandria:emptyp (uiop:split-string l :separator '(#\, #\space #\( #\))))
               (declare (ignorable rest))
               (make-helmfile-change :name resource-name :namespace namespace :kind kind :api api :change-type (get-change-type l) :lines (list))))
           (diff-output-from-line (l)
             (destructuring-bind (release-lit release chart-lit chart namespace-lit namespace)
                 (cdr (remove-if #'alexandria:emptyp (uiop:split-string l :separator '(#\, #\space #\=))))
               (declare (ignorable release-lit chart-lit namespace-lit))
               (make-helmfile-diff-output :release release :chart chart :namespace namespace :changes (list)))))
    (let ((is-inside-diff nil)
          (release-diffs nil))
      (dolist (line (serapeum:lines raw))
        (cond
          ((new-change-p line)
           (serapeum:eif-let ((change (change-from-line line))
                              (release-changes (helmfile-diff-output-changes (car release-diffs))))
             (progn
               (change-reverse-lines (car release-changes))
               (push change (helmfile-diff-output-changes (car release-diffs))))
             (setf (helmfile-diff-output-changes (car release-diffs)) (list change)))
           (setf is-inside-diff t))
          ((serapeum:string*= "Diff will show entire contents as new" line) (setf (helmfile-diff-output-new-release (car release-diffs)) t))
          ((new-release-p line) (progn (push (diff-output-from-line line) release-diffs)
                                       (setf is-inside-diff nil)))
          ((comment-line-p line) :skip)
          (is-inside-diff (push line (helmfile-change-lines (car (helmfile-diff-output-changes (car release-diffs))))))))
      release-diffs)))
