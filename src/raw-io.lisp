(in-package :trivial-raw-io)

;; For an explanation of VMIN and VTIME, see
;;
;; http://www.unixwiz.net/techtips/termios-vmin-vtime.html
(defmacro with-raw-io ((&key (vmin 1) (vtime 0)) &body body)
  "Execute BODY without echoing input IO actions."
  (declare (ignorable vmin vtime))
  
  #+sbcl
  ;; Thanks to Thomas F. Burdick
  (with-gensyms (old new bits)
    `(let ((,old (sb-posix:tcgetattr 0))
           (,new (sb-posix:tcgetattr 0))
           (,bits (logior sb-posix:icanon sb-posix:echo sb-posix:echoe
                          sb-posix:echok sb-posix:echonl)))
       (unwind-protect
            (progn
              (setf (sb-posix:termios-lflag ,new)
                    (logandc2 (sb-posix:termios-lflag ,old) ,bits)
                    (aref (sb-posix:termios-cc ,new) sb-posix:vmin) ,vmin
                    (aref (sb-posix:termios-cc ,new) sb-posix:vtime) ,vtime)
              (sb-posix:tcsetattr 0 sb-posix:tcsadrain ,new)
              ,@body)
         (sb-posix:tcsetattr 0 sb-posix:tcsadrain ,old))))

  #+ccl
  (with-gensyms (old new bits cc-array)
    `(ccl:rlet ((,old :termios)
                (,new :termios))
       (let ((,bits (logior #$ICANON #$ECHO #$ECHOE #$ECHOK #$ECHONL))
             (,cc-array (ccl:pref ,new :termios.c_cc)))
         (unwind-protect
              (progn
                ; Ensure that we actually store the original value.
                (#_tcgetattr 0 ,old)
                (setf (ccl:pref ,new :termios.c_lflag)
                      (logandc2 (ccl:pref ,old :termios.c_lflag) ,bits)
                      (ccl:paref ,cc-array (:array :char) #$VMIN) ,vmin
                      (ccl:paref ,cc-array (:array :char) #$VTIME) ,vtime)
                (#_tcsetattr 0 #$TCSADRAIN ,new)
                ,@body)
           (#_tcsetattr 0 #$TCSADRAIN ,old)))))

  #+ecl
  ()

  #+cmucl
  ;; Thanks to Rob Warnock
  ;; FIXME: Why does it return immediately?
  (with-gensyms (old new e0 e1 bits)
    `(alien:with-alien ((,old (alien:struct unix:termios))
                        (,new (alien:struct unix:termios)))
       (let ((,e0 (unix:unix-tcgetattr 0 ,old))
             (,e1 (unix:unix-tcgetattr 0 ,new))
             (,bits (logior unix:tty-icanon unix:tty-echo unix:tty-echoe
                            unix:tty-echok unix:tty-echonl)))
         (declare (ignorable ,e0 ,e1))
         (unwind-protect
              (progn
                (setf (alien:slot ,new 'unix:c-lflag)
                      (logandc2 (alien:slot ,old 'unix:c-lflag) ,bits)
                      (alien:deref (alien:slot ,new 'unix:c-cc) unix:vmin) ,vmin
                      (alien:deref (alien:slot ,new 'unix:c-cc) unix:vtime) ,vtime)
                (unix:unix-tcsetattr 0 unix:tcsadrain ,new)
                ,@body)
           (unix:unix-tcsetattr 0 unix:tcsadrain ,old)))))

  #+clisp
  ;; Thanks to Pascal Bourguignon
  `(ext:with-keyboard
     (system::input-character-char
       ,@body)))

(defun read-char (&optional (stream *query-io*)
                            (eof-error-p t)
                            eof-value
                            recursive-p)
  "Read a single character without echoing it from stream STREAM."
  (declare (ignorable stream))
  (with-raw-io ()
    (cl:read-char #+clisp ext:*keyboard-inpit*
                  #-clisp stream
                  eof-error-p
                  eof-value
                  recursive-p)))

(defun read-line (&optional (stream *query-io*)
                            (eof-error-p t)
                            eof-value
                            recursive-p)
  "Read a line without echoing it from stream STREAM."
  (declare (ignorable stream))
  (with-raw-io ()
    (cl:read-line #+clisp ext:*keyboard-inpit*
                  #-clisp stream
                  eof-error-p
                  eof-value
                  recursive-p)))
