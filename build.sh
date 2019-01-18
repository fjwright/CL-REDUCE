#!/usr/bin/bash

# Build REDUCE on Common Lisp.
# Based on "psl/bootstrap.sh" and "psl/build.sh".

# Author: Francis J. Wright <https://sourceforge.net/u/fjwright>

# Compile all required fasl files and save a final REDUCE image.

# Usage: ./build.sh

# Build an initial bootstrap REDUCE image if necessary:
if [ ! -e bootstrap.img ]; then ./bootstrap.sh; fi

mkdir -p log				 # -p avoids complaint if directory exists
mkdir -p fasl

# First, compile fasl files for non-package source files:
sbcl --core bootstrap.img --noinform << XXX &> log/build.blg
(standard-lisp)
(begin)
symbolic;

package!-remake2('clprolo, nil);
package!-remake2('revision, 'support);
package!-remake2('clrend, nil);
package!-remake2('entry, 'support);

% Create .dat files that list core and non-core modules to build:

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

bye;
XXX

# Compile the "core" modules, each in a separate invocation of
# bootstrapping REDUCE to avoid adverse interactions:

for p in $(< fasl/core-packages.dat)
do
echo ++++++ About to remake $p ++++++

# ${p,,} below converts $p to lower case.
sbcl --core bootstrap.img --noinform << XXX &> log/${p,,}.blg
(standard-lisp)
(begin)
symbolic;

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

# Start a new invocation of Lisp and load the key modules compiled
# above.  Then save a final REDUCE image that wil be used below to
# compile the non-core modules.

sbcl --noinform << XXX &> log/reduce.blg
(load "sl-on-cl")
(standard-lisp)

(defparameter !*init!-stats!* (list (time) (gtheap)))

(setq !*verboseload t)
(defvar !*argnochk t)           % Check argument count.

% Load is expected to be a macro but isn't; does that matter?

(load "module")                 % Contains definition of load-package.
(load "clprolo")                % Initial CL specific code.

(load!-package 'revision)
(load!-package 'rlisp)
(load!-package 'clrend)
(load!-package 'poly)
(load!-package 'arith)
(load!-package 'alg)
(load!-package 'mathpr)
(load!-package 'entry)
(defautoload prettyprint pretty)  % since only in entry file for PSL!

(setq date!* (date))
(setq version!* (format nil "REDUCE (Free SBCL version, revision ~a)" revision!*))
(initreduce)

(setq !*verboseload nil)           % Inhibit loading messages.

(setf sb-ext:*muffled-warnings* 'warning)

(prog nil
   (terpri)
   (prin2 "Time to build REDUCE: ")
   (prin2 (quotient (difference (time) (car !*init!-stats!*)) 1000.0))
   (prin2t " secs")
   (prin2 "Heap used: ")
   (prin2t (difference (cadr !*init!-stats!*) (gtheap)))
   (prin2t " bytes")
   (prin2 "Heap left: ")
   (prin2t (gtheap))
   (prin2t " bytes")
   (setq !*init!-stats!* nil))

% (savesystem "REDUCE" "$fasl/reduce" (quote ((read-init-file "reduce"))))
% SBCL (see SBCL User Manual / Stopping SBCL / Saving a Core Image):
% (save!-lisp!-and!-die "reduce" !:executable t !:toplevel (lambda () (standard-lisp) (begin)))
(save!-lisp!-and!-die "reduce.img") % better for debugging

XXX

echo 'Errors:'
grep --exclude=bootstrap.blg '\*\*\*\*\*\|\<error\>' log/*.blg

echo $'\a'

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
