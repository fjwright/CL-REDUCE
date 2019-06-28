REDUCE on Common Lisp
=====================

Francis Wright, June 2019

From the introductory chapter of [*Common Lisp the Language, 2nd edition*, by Guy L. Steele Jr.](https://www.cs.cmu.edu/Groups/AI/html/cltl/cltl2.html):

> The goals of Common Lisp are thus very close to those of Standard Lisp and Portable Standard Lisp. Common Lisp differs from Standard Lisp primarily in incorporating more features, including a richer and more complicated set of data types and more complex control structures.

**This code is currently experimental!**

The files in this directory are intended to build and run the current distributed version of REDUCE on ANSI Common Lisp.  Some details depend on the implementation of Common Lisp but I try to keep these to a minimum.  At present, I support explicitly only

* the native Microsoft (MS) Windows and Linux builds of [SBCL](http://www.sbcl.org/) (Steel Bank Common Lisp),
* the [Cygwin](https://cygwin.com/) and Linux builds of [CLISP](https://clisp.sourceforge.io/),

but in the longer term I may also consider supporting another implementation of Common Lisp such as GCL (GNU Common Lisp).

Building REDUCE
---------------

Create a build directory somewhere convenient.  If you download the whole [REDUCE trunk](https://sourceforge.net/p/reduce-algebra/code/HEAD/tree/trunk/) then you can use the `common-lisp` directory as your build directory with no additions.

**You need the following software and files:**

An appropriate version of SBCL and/or CLISP (see links above).  CLISP on Linux should be available via a Linux package manager such as Synaptic (but not via a software installer for windowed applications).

A minimal Unix-like environment including `bash` and `grep`; on MS Windows I use [Cygwin](https://cygwin.com/).  (The `grep` command is used only for reporting an error summary, which could be commented out without affecting the build process.)

The build directory must contain the following files from the common-lisp directory:

* `sl-on-cl.lisp`
* `trace.lisp`
* `clprolo.red`
* `clrend.red`
* `build.red`
* `remake.red`
* `bootstrap.sh`
* `build.sh`
* `gnuintfc.red` (for `gnuplot` support on MS Windows only, but it could be commented out in `build.sh`)

Ensure that the `*.sh` files are executable.

If you do not build within the REDUCE trunk file tree then the following two steps are also necessary:

* The build directory must also contain a link to or copy of the file [psl/boot.sl](https://sourceforge.net/p/reduce-algebra/code/HEAD/tree/trunk/psl/boot.sl).  (The way to create a link in Windows is with the `mklink` command at a Windows command prompt; I use a symbolic link for `boot.sl`.  A Windows shortcut created using the File Explorer GUI will probably not work!)

* The `packages` directory of the version of REDUCE you want to build must be available and you need to set the environment variable `$reduce` to the directory containing this directory.  The `packages` directory is installed as part of a binary distribution so, for example, if you have a _default_ REDUCE installation on Windows then an appropriate value for `$reduce` would be `"C:\Program Files\Reduce"` (in Windows format).  You can also use a recent download from the [Subversion repository](https://sourceforge.net/p/reduce-algebra/code/HEAD/tree/trunk/).

Open a window running `bash` and make your chosen build directory current.  If necessary (see above), set the `$reduce` environment variable.  For example, execute the `bash` command

    export reduce='C:/Program Files/Reduce'

Run the build script by executing the `bash` command

    ./build.sh -l lisp

where `lisp` is either `sbcl` or `clisp`.

The build process should create two sub-directories in the build directory called `fasl` and `log`.  The whole `log` directory and the `*.lisp`, `*.dat` and `bootstrap.*` files in the `fasl` directory could be deleted after the build; only the files `fasl/reduce.*` and `fasl/*.fas*` are required to run REDUCE.  (I will probably delete superfluous files automatically at some later date, but for now they are useful for debugging.)  The SBCL and CLISP builds can in principle coexist since they use different extensions for fasl and memory image file names.

Running REDUCE
--------------

**SBCL REDUCE** can be run on MS Windows by double-clicking the file `redsbcl.bat`, or from a Windows command prompt with the build directory current by executing the command

    redsbcl

(Don't try to run Windows SBCL interactively under `bash` because you'll probably find that input editing doesn't work as you would wish; fortunately, it runs fine in batch mode under `bash`.)

On Linux, open a terminal window and execute the command

    ./redsbcl

having ensured that it is executable.  Beware that this interface does not provide any input editing, although it runs fine in an Emacs shell buffer.

**CLISP REDUCE** can be run on MS Windows or Linux by executing the `bash` command

    clisp -q -M fasl/reduce.mem

and then evaluating the Lisp form

    (start-reduce)

(I will provide a more elegant start-up procedure eventually.)

REDUCE can be run from any directory provided the command to start it is specified suitably, such as by using an absolute file path for the `redsbcl` command (for SBCL) or for the `fasl` directory (for CLISP).  Alternatively (for SBCL), you can add the `common-lisp` directory to your path and then run SBCL REDUCE via the command `redsbcl` (on both Windows and Linux).

On both Lisps, interrupting REDUCE (with Control-C) invokes the Lisp debugger and aborting that enters Lisp, which is very useful for low-level debugging!  Evaluate `(begin)` to get back into REDUCE.

Implementation-specific functionality
-------------------------------------

The following facilities are modelled on those provided by PSL; please see the PSL manual for further details.

Lisp-level function tracing is provided by the commands `tr` and `trst`.  A command of the form `tr fn1, fn2, ...;` (without any quotes) enables tracing of the argument and return values of each of the functions `fn1`, `fn2`, etc.; if no functions are specified it lists all traced functions.  The command `trst` is similarly but also traces assignments, which works for functions that have been compiled using `faslout` provided the appropriate Lisp file is still available in the `fasl` directory.  The commands `untr` and `untrst` (which is just a synonym for `untr`) disable tracing; if no functions are specified they untrace all traced functions.  These tracing commands are independent of the Common Lisp `trace` and `untrace` macros.  Input of function names uses Standard Lisp (i.e. REDUCE) syntax but output uses Common Lisp syntax, although it does not include any package prefixes, which can make Common Lisp tracing output of REDUCE incomprehensible!

Preliminary implementations of the `system`, `pipe-open` and `channelflush` functions are provided but only for Microsoft Windows and Cygwin at present.  The functions `getenv` and `getpid` respectively provide access to environment variables and the REDUCE process identifier, and should be portable across operating systems.

The commands `pwd()` or `cd "<directory>"` respectively return or change (and return) the current working directory.  The name `chdir` is an alias for `cd`.

Environment variables and dots ("." or "..") in filenames are expanded by `cd/chdir` and `open` relative to the current working directory of the REDUCE process.

Current status
--------------

The process described above should build all of REDUCE without any obvious errors.  So far, I have avoided the need to customise the main REDUCE source code (apart from the file `gnuintfc.red`).

All available test files produce output that agrees with CSL REDUCE apart for timings and minor numerical and/or implementation differences, except for the following:

* The `reduce4` test fails in a similar way as on CSL &ndash; excluded from regular testing.
* The `ibalp` test fails on CLISP with a program stack overflow error; it just stops abruptly on SBCL &ndash; excluded from regular testing.
* The `pasf` test output appears to be mathematically correct but is ordered differently on CLISP, whereas it agrees on SBCL (and appears to run twice as fast as on CSL!).
* The `lalr` test output appears to be correct apart from two issues causing minor cosmetic differences.
* The `rubi_red` test is very slow, generates very much output, and timeouts can't work on CLISP (see below), but otherwise the early part of the test file appears to run correctly &ndash; excluded from regular testing.  On SBCL, the first error is similar to that shown on CSL, but SBCL REDUCE does not recover after this error, probably due to the currently crude general error handling.

Note that the `xcolor` test file only runs to completion (only tested on SBCL) with `(declaim (optimize speed))`. I think this is because it involves a highly recursive procedure (color1), which runs out of stack on the most complicated examples at the end of the test file unless optimized for maximum speed.

Timings
-------

New timing methodology uses the bash time command.  "Best" means the fastest previous time.

**Timing on Microsoft Windows** (on a fairly recent Intel Core i5 processor):

Operation                               | CSL Time  | Best SBCL | This SBCL | Best CLISP | This CLISP
----------------------------------------|-----------|-----------|-----------|------------|-----------
Run (and check) all core test files     |  30 secs  |  47 secs  |           |  3 m 23 s  |
Run (and check) most noncore test files |  4 m 13 s | 15 m 14 s |           | 67 m 27 s  |

**Timing on Ubuntu Linux** (on a fairly old Intel Core Duo processor):

Operation                               | CSL Time  | Best SBCL | This SBCL | Best CLISP | This CLISP
----------------------------------------|-----------|-----------|-----------|------------|-----------
Run (and check) all core test files     |
Run (and check) most noncore test files |

The CSL test times do not include checking, which involves running `diff`.  The times for the noncore tests do not include `reduce4`, `ibalp` or `rubi_red` as explained above, and `gnuplot` and `turtle` are excluded because they need to be run interactively.

Known limitations
-----------------

I cannot see any way to support the facilities for restricting execution time on CLISP.  In more detail: the file "rlisp/inter.red" defines procedures `with!-timeout` and similar that use garbage collection to provide an interrupt by assigning a function to the variable `!*gc!-hook!*`, but no garbage collection hooks exist in CLISP.  The procedures `with!-timeout` and similar just run without any restriction so don't use CLISP REDUCE is you need this facility!  This affects `rubi_red` and possibly other packages.  It works on SBCL!

To do
-----

In `alg/intro.red`, `outputhandler*` is undefined. Should be declared fluid. Done temporarily in `clrend`.

In `rlisp/io.red`, `in` uses `mkfil*` but `out` and `shut` use `mkfil`; why the inconsistency?  [Not currently a problem for me as far as I'm aware.]

Make faslout/faslend more robust by using a single function that calls begin internally (cf. infile) and make faslend generate a throw.  (See also the old mkfasl code?)

Optimise SL-on-CL to improve its speed.

Better error handling.

Implement a proper Lisp init function (and possibly dump an executable file).

Replace shell scripts with Common Lisp code to build REDUCE portably?

Implement a genuinely lower-case Standard Lisp, perhaps using case-inversion for a few special symbols such as `lambda`, `nil`, `t`?

Hide the implementation details within an implementation package and only export required functions to the STANDARD-LISP package?
