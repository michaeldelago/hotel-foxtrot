(defpackage hotel-foxtrot/tests/main/helmfile
  (:use :cl :fiveam))
(in-package #:hotel-foxtrot/tests/main/helmfile)

;; NOTE: To run this test file, execute `(asdf:test-system :hotel-foxtrot)' in your Lisp.
;;

(def-suite* helmfile)

(test helmfile-selector-encode
  (is (equal (hotel-foxtrot.helmfile::encode-helmfile-selector '()) ""))
  (is (equal (hotel-foxtrot.helmfile::encode-helmfile-selector '(("name" . "foobar")))
             "name=foobar"))
  (is (equal (hotel-foxtrot.helmfile::encode-helmfile-selector '(("name" . "foobar")
                                                                 ("chart" . "foobar")))
             "name=foobar,chart=foobar"))
  (is (equal (hotel-foxtrot.helmfile::encode-helmfile-selector (serapeum:dict "chart" "foobar"
                                                                              "name" "foobar"))
             "name=foobar,chart=foobar")))

(test helmfile-selector-decode
  (is (equal (hotel-foxtrot.helmfile::decode-helmfile-selector "") '()))
  (is (equal (hotel-foxtrot.helmfile::decode-helmfile-selector "name=foobar")
             '(("name" . "foobar"))))
  (is (equal (hotel-foxtrot.helmfile::decode-helmfile-selector "name=foobar,chart=foobar")
             '(("name" . "foobar")
               ("chart" . "foobar")))))
