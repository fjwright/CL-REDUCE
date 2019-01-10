#!/usr/bin/bash

# Modified by FJW for REDUCE on Common Lisp.
# The standard version is "psl/bootstrap.sh".

# Build an initial bootstrap REDUCE core image that can be used to
# compile the rest of the system.

# Usage: ./bootstrap.sh

mkdir -p log				 # -p avoids complaint if directory exists
mkdir -p fasl

echo ++++++ Build bootstrap REDUCE ++++++

# This starts with the normal distributed version of SBCL and creates
# a bootstrap version of the REDUCE parser. It uses the resulting
# very initial version of a REDUCE core to compile key REDUCE modules
# that are needed when re-compiling the rest of the system. It does
# not checkpoint itself at the end of this because the general Lisp
# environment will be in a somewhat untidy state, so a separate stage
# will load up the modules compiled here and checkpoint them to make
# the REDUCE bootstrap build system.

sbcl << XXX &> log/bootstrap.blg

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
   (terpri)
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

% Create the .dat files that indicate which modules will need building

begin
  scalar w, i, s, core, noncore;
  i := open("packages/package.map", 'input);
  s := rds i;
  w := read();
  rds s;
  close i;
  for each x in w do
     if member('psl, x) then <<
        if member('core, x) then core := x . core
        else noncore := x . noncore >>;
  i := open("fasl/core-packages.dat", 'output);
  s := wrs i;
  for each x in reverse core do print car x;
  wrs s; % ADDED TO AVOID A NASTY CRASH!
  close i;
  i := open("fasl/noncore-packages.dat", 'output);
  s := wrs i;
  for each x in reverse noncore do print car x;
  wrs s;
  close i;
end;

% Without above addition, penultimate wrs returns the closed stream
% for "fasl/core-packages.dat" and then the final wrs tries to switch
% to the closed stream. This crashes SBCL!

initreduce();

% SBCL (see SBCL User Manual / Stopping SBCL / Saving a Core Image):
% save!-lisp!-and!-die("bootstrap", !:executable, t, !:toplevel, (lambda () (standard-lisp) (begin)))
save!-lisp!-and!-die "bootstrap.img"; % better for debugging

XXX

echo ++++++ Bootstrap REDUCE built ++++++
