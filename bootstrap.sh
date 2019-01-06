#!/usr/bin/bash

# Modified by FJW for REDUCE on Common Lisp.
# The standard version is "psl/bootstrap.sh".

# Build an initial bootstrap REDUCE core image that can be used to
# compile the rest of the system.

# Usage: ./bootstrap.sh

mkdir -p buildlogs			 # -p avoids complaint if buildlogs exists
mkdir -p fasl

echo ++++++ Build bootstrap REDUCE ++++++

sbcl << XXX &> buildlogs/bootstrap.blg

;; This starts with the normal distributed version of SBCL and creates
;; a bootstrap version of the REDUCE parser. It uses the resulting
;; very initial version of a REDUCE core to compile key REDUCE modules
;; that are needed when re-compiling the rest of the system. It does
;; not checkpoint itself at the end of this because the general Lisp
;; environment will be in a somewhat untidy state, so a separate stage
;; will load up the modules compiled here and checkpoint them to make
;; the REDUCE bootstrap build system.

(declaim (optimize debug)				; same as (debug 3)
		 (sb-ext:muffle-conditions sb-ext:compiler-note style-warning))

(load "sl-on-cl.lisp")					; no point using fasl version
(standard-lisp)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% STANDARD LISP SYNTAX FROM NOW ON! %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

(setq !*verboseload t)

(defparameter !*init!-time!* (time))

(defvar !*argnochk t)
(defvar !*int nil)                      % Prevents input buffer being saved.
(defvar !*msg nil)
% (setq !*comp t)                       % It's faster if we compile the boot file.

% Do not use fasl version of "boot.sl": the CL compiler may optimize
% away (i.e. discard) uses of fluid variables that are needed later in
% the build process!

(load "boot.sl")

(defvar xxx)

(begin2)
rds(xxx := open("build.red",'input));
(close xxx)

(load!-package!-sources 'clprolo nil)
(load!-package!-sources 'revision 'support)
(load!-package!-sources 'rlisp 'rlisp)
(load!-package!-sources 'clrend nil)
(load!-package!-sources 'poly 'poly)
(load!-package!-sources 'alg 'alg)
(load!-package!-sources 'arith 'arith)  %  Needed by roots, specfn*, (psl).
%(load!-package!-sources 'mathpr 'mathpr) % only for testing above modules
(load!-package!-sources 'entry 'support)
(load!-package!-sources 'remake nil)

(setq !*comp nil)

(prog nil
   (gc)
   (prin2 "Time to build bootstrapping REDUCE: ")
   (prin2 (quotient (difference (time) !*init!-time!*) 1000.0))
   (prin2t " secs")
%   (prin2 "Heap left:      ")
%   (prin2t (gtheap nil))
%   (prin2 "BPS left:       ")
%   (prin2t (free-bps))
)

(initreduce)
(setq date!* (date))
(setq version!* "Bootstrapping REDUCE")

(begin)
symbolic;
load compiler;
package!-remake2('clprolo, nil);
package!-remake2('revision, 'support);
package!-remake2('clrend, nil);
package!-remake2('entry, 'support);
package!-remake2('remake, nil);

% SBCL (see SBCL User Manual / Stopping SBCL / Saving a Core Image):
% save!-lisp!-and!-die("bootstrap", !:executable, t, !:toplevel, (lambda () (standard-lisp) (begin)))
save!-lisp!-and!-die "bootstrap.img"; % better for debugging

XXX

echo ++++++ Bootstrap REDUCE built ++++++
