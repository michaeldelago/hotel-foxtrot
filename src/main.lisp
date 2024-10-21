(uiop:define-package hotel-foxtrot
  (:use #:cl))
(in-package #:hotel-foxtrot)

;; (yesql:import helmfile-db
;;   :from "sql/queries.sql"
;;   :as :cl-yesql/postmodern
;;   :binding :all-functions)

;; (postmodern:with-connection '("hotel-foxtrot" "hotel-foxtrot" "foo-password" "localhost" :pooled-p t :port 5432)
;;   (get-diff-for-service :namespace "dev" :release "my-service"))
