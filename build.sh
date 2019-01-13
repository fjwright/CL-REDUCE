#!/usr/bin/bash

# Modified by FJW for REDUCE on Common Lisp.
# The standard version is "psl/build.sh".

# Do a complete rebuild of REDUCE, assuming ./bootstrap.sh has been
# run to build an initial bootstrap REDUCE core image.

# Usage: ./build.sh

# Compile the "core" modules.  These are each built in a
# freshly-loaded system since otherwise there can be bad effects from
# left-over declarations and the like.

mkdir -p log				 # -p avoids complaint if directory exists

for p in `cat fasl/core-packages.dat`
do
echo ++++++ About to remake $p ++++++

# ${p,,} below converts $p to lower case.
sbcl --core bootstrap.img --noinform << XXX &> log/${p,,}.blg
(standard-lisp)
(begin)
symbolic;
on verboseload;
load compiler;
load remake;
!*argnochk := t;

begin
  scalar w, i, s;
  i := open("packages/package.map", 'input);
  s := rds i;
  w := read();
  rds s;
  close i;
  for each x in w do put(car x, 'folder, cadr x)
end;

package!-remake '$p;

bye;
XXX

done

echo ++++++ Now create the REDUCE image file ++++++

# This starts a bare Common Lisp image and loads in the modules
# compiled by the very first step.  It then checkpoints a system that
# can be used to rebuild all other modules.

sbcl --noinform << XXX &> log/reduce.blg
(load "sl-on-cl")
(standard-lisp)

%(setq !*init!-stats!* (list (time) (gtheap nil) (free-bps) nextsymbol))
(defparameter !*init!-stats!* (list (time)))

(setq !*verboseload t)
(defvar !*argnochk t)           % Check argument count.

% Load is expected to be a macro but isn't; does that matter?

(load "module")                 % Contains definition of load-package.
(load "clprolo")                % CL specific code.

(load!-package 'revision)
(load!-package 'rlisp)
(load!-package 'clrend)
(load!-package 'poly)
(load!-package 'arith)
(load!-package 'alg)
(load!-package 'mathpr)
(load!-package 'entry)
(defautoload prettyprint pretty) % since only in entry for PSL!

(setq date!* (date))
(setq version!* "REDUCE Experimental Version")
(initreduce)

% (setq !*loadversion t)             % Load entry module during BEGIN.
(setq !*verboseload nil)           % Inhibit loading messages.
(setf sb-ext:*muffled-warnings* 'warning)

(prog nil
   (gc)
   (terpri)
   (prin2 "Time to build core REDUCE: ")
   (prin2 (quotient (difference (time) (car !*init!-stats!*)) 1000.0))
   (prin2t " secs")
   % (prin2 "Symbols used:   ")
   % (prin2t (difference nextsymbol (cadddr !*init!-stats!*)))
   % (prin2 "Heap used:      ")
   % (prin2t (difference (cadr !*init!-stats!*) (gtheap nil)))
   % (prin2 "BPS used:       ")
   % (prin2t (difference (caddr !*init!-stats!*) (free-bps)))
   % (prin2 "Heap left:      ")
   % (prin2t (gtheap nil))
   % (prin2 "BPS left:       ")
   % (prin2t (free-bps))
  (setq !*init!-stats!* nil))

% (savesystem "REDUCE" "$fasl/reduce" (quote ((read-init-file "reduce"))))
% SBCL (see SBCL User Manual / Stopping SBCL / Saving a Core Image):
% (save!-lisp!-and!-die "reduce" !:executable t !:toplevel (lambda () (standard-lisp) (begin)))
(save!-lisp!-and!-die "reduce.img") % better for debugging

XXX

exit

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# Now I can re-build the remaining packages using the genuine
# final reduce.img rather than just the bootstrap one

for p in `$catcmd < $cfasl/noncore-packages.dat`
do
echo ++++++ About to make noncore $p ++++++

psl/bpsl -td $STORE -f red/reduce.img <<XXX > log/$p.blg

symbolic;

load compiler;
errorset('(load compat),nil,nil); % PSL compiler support.
on verboseload;

% Specific package loads to avoid BPS problems.
if '$p eq 'susy2 then flag('(susy2),'lap)
else if '$p eq 'fps then load_package limits,factor,specfn,sfgamma
else if '$p eq 'mrvlimit then load_package taylor;

load remake;

!*argnochk := t;

begin
  scalar w, i, s;
  i := open("$reduce/packages/package.map", 'input);
  s := rds i;
  w := read();
  rds s;
  close i;
  for each x in w do put(car x, 'folder, cadr x)
end;

package!-remake '$p;

bye;
XXX

done
