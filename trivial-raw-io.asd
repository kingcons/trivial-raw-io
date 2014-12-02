(defsystem :trivial-raw-io
  :name "trivial-raw-io"
  :description "Helpers for doing raw POSIX I/O"
  :version "0.0.2"
  :license "BSD"
  :author "Brit Butler <redline6561@gmail.com>"
  :maintainer "Brit Butler <redline6561@gmail.com>"
  :depends-on (:alexandria #+sbcl :sb-posix)
  :components ((:module src
                :components ((:file "packages")
                             (:file "raw-io"
                                    :depends-on ("packages"))))))
