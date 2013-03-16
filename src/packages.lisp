(defpackage :trivial-raw-io
  (:use :cl)
  (:import-from :alexandria #:with-gensyms)
  (:shadow #:read-char
           #:read-line)
  (:export #:with-raw-io
           #:read-char
           #:read-line))
