(defpackage hotel-foxtrot/tests
  (:use :cl :fiveam))
(in-package :hotel-foxtrot/tests)

;; NOTE: To run this test file, execute `(asdf:test-system :hotel-foxtrot)' in your Lisp.

(def-suite* main)

(test default
  (is (= 1 1)))
