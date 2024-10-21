(defsystem "hotel-foxtrot"
  :version "0.0.1"
  :author ""
  :license ""
  :depends-on (:serapeum :alexandria :uiop  :log4cl :log4cl-extras :cl-yesql :cl-yesql/postmodern :com.inuoe.jzon)
  :components ((:module "src"
                :components
                ((:module "helmfile"
                  :serial t
                  :components
                  ((:file "package")
                   (:file "parse-diff")
                   (:file "main")))
                 (:file "main"))))
  :description ""
  :in-order-to ((test-op (test-op "hotel-foxtrot/tests"))))

(defsystem "hotel-foxtrot/tests"
  :author ""
  :license ""
  :depends-on ("hotel-foxtrot"
               "fiveam")
  :components ((:module "tests"
                :components
                ((:file "main")
                 (:module "helmfile"
                  :components
                  ((:file "main")
                   (:static-file "fresh-install.yaml.diff")
                   (:file "parse-diff") )))))
  :description "Test system for hotel-foxtrot"
  :perform (test-op (op c) (symbol-call :fiveam :run-all-tests)))
