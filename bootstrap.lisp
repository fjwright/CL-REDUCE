;; Common Lisp code to build a REDUCE image for bootstrapping
(load "sl-on-cl")

(unless (sl:getenv "reduce")
  ;; No easy way to support setenv in ABCL, so $reduce must be set explicitly!
  (cond #-ABCL ((probe-file "./packages") (sl:setenv "reduce" "."))
        #-ABCL ((probe-file "../packages") (sl:setenv "reduce" ".."))
        (t (print "Error: cannot find packages directory.  Please set $reduce.") (sl:exit 1))))

#-DEBUG (declaim (optimize speed))
#+DEBUG (declaim (optimize debug safety))
#+SBCL (declaim (sb-ext:muffle-conditions sb-ext:compiler-note style-warning))
#+CLISP (setq custom:*suppress-check-redefinition* t
              custom:*compile-warnings* nil)
#+ABCL (progn
         (require :abcl-contrib)
         (require :asdf-jar) ;; seems to imply (require "asdf")
         ;; Process .asd files in the current directory only.
         (asdf:initialize-source-registry
          `(:source-registry (:directory ,*default-pathname-defaults*)
                             :ignore-inherited-configuration)))

(standard-lisp)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% STANDARD LISP SYNTAX FROM NOW ON! %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

(setq !*verboseload t)
(setq !*redefmsg nil)           % Just duplicates CL warnings!

(cl:defparameter !*init!-time!* (time))

(cl:defvar !*argnochk t)
(cl:defvar !*int nil)  % Prevents input buffer being saved.
(cl:defvar !*msg nil)

% Do not use fasl version of "boot.sl": the CL compiler may optimize
% away (i.e. discard) uses of fluid variables that are needed later in
% the build process!

(cond ((filep "boot.sl") (load "boot.sl"))
      ((filep "../psl/boot.sl") (load "../psl/boot.sl"))
      (t (error 0 "Cannot find boot file.") (exit 1)))

(setq !*comp t)  % It's faster in some lisps if we compile.

(load "build.sl")

(load!-package!-sources 'clprolo nil)
(load!-package!-sources 'revision 'support)
(load!-package!-sources 'rlisp 'rlisp)
(load!-package!-sources 'smacros 'support)
(load!-package!-sources 'clrend nil)
(load!-package!-sources 'poly 'poly)
(load!-package!-sources 'alg 'alg)
(load!-package!-sources 'rtools 'rtools)  % https://sourceforge.net/p/reduce-algebra/code/5845/
(load!-package!-sources 'arith 'arith)
(load!-package!-sources 'entry 'support)
(load!-package!-sources 'remake nil)

(setq !*comp nil)

% (load "compiler")

(prog nil
   (terpri)
   (prin2 "Time to build bootstrap REDUCE: ")
   (prin2 (quotient (difference (time) !*init!-time!*) 1000.0))
   (prin2t " secs")
   (prin2 "Heap left: ")
   (prin2 (gtheap))
   (prin2t " bytes")
)

(initreduce)
(setq date!* (date))
(setq version!* "Bootstrap REDUCE")
(cond ((or (memq 'sbcl lispsystem!*) (memq 'clisp lispsystem!*))
       (save!-reduce!-image "bootstrap")))
