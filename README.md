## trivial-raw-io

For all your portable CL raw POSIX I/O needs!
We export three simple symbols: `with-raw-io`, `read-char`, and `read-line`.

Obviously, read-char and read-line shadow the existing CL symbols. We simply call them inside `with-raw-io`.

`with-raw-io` is a macro which takes a *&body* and executes **BODY** with IO in [non-canonical mode](http://en.wikipedia.org/wiki/POSIX_terminal_interface#Non-canonical_mode_processing) by modifying [POSIX termios](http://en.wikipedia.org/wiki/POSIX_terminal_interface#The_termios_data_structure) settings, then restores the previous settings.

At this time, trivial-raw-io has been tested on: SBCL, CCL, CMUCL, and CLISP. All testing has been done on Linux.
