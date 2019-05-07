#!/usr/bin/bash

# Build REDUCE on Common Lisp.
# Based on "psl/bootstrap.sh" and "psl/build.sh".

# Author: Francis J. Wright <https://sourceforge.net/u/fjwright>

# Compile all required fasl files and save a final REDUCE image.
# Assume this script is run in the top-level CL REDUCE directory.

# Usage: ./build.sh [-c]

# Option -c ensures a clean build by deleting any previous build.
# Option -f forces recompilation of all packages.
if getopts cf option
then
    if [ $option = c ]; then rm -rf fasl log;
    elif [ $option = f ]; then force='!*forcecompile := t;'; fi
fi

if [ ! "$reduce" ]; then export reduce=.; fi

# Build an initial bootstrap REDUCE image if necessary:
# if [ ! -e fasl/bootstrap.img ]; then ./bootstrap.sh; fi
if [ ! -e fasl/bootstrap.mem ]; then ./bootstrap.sh; fi

mkdir -p log                 # -p avoids complaint if directory exists

shopt -s expand_aliases

# runlisp='sbcl'
runlisp='clisp -ansi'
# runbootstrap='sbcl --noinform --core fasl/bootstrap.img'
runbootstrap='clisp -q -M fasl/bootstrap.mem'

alias grep_errors=\
"grep --ignore-case '\*\{5\} \| \<error\>\|COMMON-LISP:ERROR' log/\$p.blg | uniq"

# First, compile fasl files for non-package source files:
$runbootstrap << XXX &> log/build.blg
(standard-lisp)
(begin)
symbolic; $force

package!-remake2('clprolo, nil);
package!-remake2('revision, 'support);
package!-remake2('clrend, nil);
package!-remake2('entry, 'support);
package!-remake2('remake, nil); % for building noncore packages

% Create .dat files that list core and non-core modules to build:

begin
  scalar w, i, s, core, noncore;
  i := open("$reduce/packages/package.map", 'input);
  s := rds i;
  w := read();
  rds s;
  close i;
  for each x in w do
     if member('csl, x) and member('psl, x) then <<
        if member('core, x) then core := x . core
        else noncore := x . noncore >>;
  i := open("fasl/core-packages.dat", 'output);
  s := wrs i;
  for each x in reverse core do print car x;
  wrs s;
  close i;
  i := open("fasl/noncore-packages.dat", 'output);
  s := wrs i;
  for each x in reverse noncore do print car x;
  wrs s;
  close i;
end;

bye;
XXX

# Compile the "core" packages, each in a separate invocation of
# bootstrap REDUCE to avoid adverse interactions:

for p in $(< fasl/core-packages.dat)
do
echo +++++ Remaking core package $p

$runbootstrap << XXX &> log/$p.blg
(standard-lisp)
(begin)
symbolic; $force

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

grep_errors

done

# if [ "sl-on-cl.lisp" -nt "sl-on-cl.fasl" ]
if [ "sl-on-cl.lisp" -nt "sl-on-cl.fas" ]
then
echo +++++ Compiling sl-on-cl
$runlisp << XXX &> log/sl-on-cl.blg
(compile-file "sl-on-cl")
XXX
fi

# if [ "trace.lisp" -nt "trace.fasl" ]
if [ "trace.lisp" -nt "trace.fas" ]
then
echo +++++ Compiling trace
$runlisp << XXX &> log/trace.blg
(load "sl-on-cl")
(compile-file "trace")
XXX
fi

echo +++++ Creating the REDUCE image file

# Start a new invocation of Lisp and load the key modules compiled
# above.  Then save a final REDUCE image that will be used below to
# compile the non-core modules.

$runlisp << XXX &> log/reduce.blg
;(declaim (optimize debug)              ; same as (debug 3)
;        (sb-ext:muffle-conditions sb-ext:compiler-note style-warning))

(load "sl-on-cl") (load "trace") ; temporary -- until I can arrange autoloading!
(standard-lisp)

(cl:defparameter !*init!-stats!* (list (time) (gtheap)))

(setq !*verboseload t)
(setq !*redefmsg nil)
(cl:defvar !*argnochk t)        % check argument count

% Load is expected to be a macro but isn't; does that matter?

(load "module")                 % for definition of load-package
(load "clprolo")                % initial CL specific code

(load!-package 'revision)
(load!-package 'rlisp)
(load!-package 'clrend)
(load!-package 'poly)
(load!-package 'arith)
(load!-package 'alg)
(load!-package 'mathpr)
(load!-package 'entry)

(cl:fmakunbound 'prettyprint)   % otherwise defautoload has no effect!
(defautoload prettyprint pretty)  % since only in entry file for PSL!

(setq date!* (date))
(setq version!* (cl:format nil "REDUCE (Free ~a version, revision ~a)"
      (cond ((memq 'sbcl lispsystem!*) "SBCL")
            ((memq 'clisp lispsystem!*) "CLISP"))
      revision!*))

(initreduce)

(setq !*verboseload nil)        % inhibit loading messages
(setq !*redefmsg t)             % display redefinition messages

% (if (memq 'sbcl lispsystem!*) (setq sb-ext:*muffled-warnings* 'warning))
% ***** I think CLISP still tries to parse this and complains about the sb-ext package! *****

(prog nil
   (terpri)
   (prin2 "Time to build REDUCE: ")
   (prin2 (quotient (difference (time) (car !*init!-stats!*)) 1000.0))
   (prin2t " secs")
   (prin2 "Heap used: ")
   (prin2 (difference (cadr !*init!-stats!*) (gtheap)))
   (prin2t " bytes")
   (prin2 "Heap left: ")
   (prin2 (gtheap))
   (prin2t " bytes")
   (cl:makunbound '!*init!-stats!*))

% (savesystem "REDUCE" "$fasl/reduce" (quote ((read-init-file "reduce"))))
% SBCL (see SBCL User Manual / Stopping SBCL / Saving a Core Image):
% (save!-lisp!-and!-die "fasl/reduce" !:executable t !:toplevel (lambda () (standard-lisp) (begin)))
% For better debugging...
(cond ((memq 'sbcl lispsystem!*)
       (save!-lisp!-and!-die "fasl/reduce.img"))
      ((memq 'clisp lispsystem!*)
       (saveinitmem "fasl/reduce.mem"))
)

XXX

# Finally, compile the "noncore" packages using reduce.img rather than
# bootstrap.img.

for p in $(< fasl/noncore-packages.dat)
do
echo +++++ Remaking noncore package $p

# sbcl --noinform --core fasl/reduce.img << XXX &> log/$p.blg
clisp -q -M fasl/reduce.mem << XXX &> log/$p.blg
(standard-lisp)
(begin)
symbolic; $force

%load compiler;
on verboseload;

if '$p eq 'fps then load_package limits,factor,specfn,sfgamma
else if '$p eq 'mrvlimit then load_package taylor
% Temporary hack to avoid build errors:
else if '$p eq 'tmprint then <<
   lispsystem!* := 'psl . lispsystem!*;
   switch usermode >>
% Temporary hack to partially fix a letter-case issue:
else if '$p eq 'sstools then put('d,'prifn,'bigdpri); % 'd was '!d

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

% Hack to make gnuplot work:
if '$p eq 'gnuplot then
   begin scalar !*int, !*forcecompile; !*forcecompile := t;
      update!-fasl2('gnuintfc, nil);
   end;

bye;
XXX

grep_errors

done

echo $'\a'
