## trivial-raw-io

For all your portable CL raw POSIX I/O needs!
We export three simple symbols: `with-raw-io`, `read-char`, and `read-line`.

Obviously, read-char and read-line shadow the existing CL symbols. We simply call them inside `with-raw-io`.

`with-raw-io` is a macro taking a *&body* which executes BODY without echoing the input IO actions by modifying POSIX termios settings.

At this time, trivial-raw-io should be portable to: SBCL, CCL, CMUCL, and CLISP. All testing has been done on Linux.
