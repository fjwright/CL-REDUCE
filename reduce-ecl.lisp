(let (*load-verbose*)
  (load "fasl.ecl/sl-on-cl.fasc")
  (load "fasl.ecl/trace.fasc"))

(standard-lisp)

%% (setq !*verboseload t)       % default is nil
(setq !*redefmsg nil)           % default is t
(cl:defvar !*argnochk t)        % check argument count

(load "fasl.ecl/module")        % for definition of load-package
(load "fasl.ecl/clprolo")       % initial CL specific code

% NB: revision!* is declared fluid and checked in "rlisp/rlisp.red".
(cl:defvar revision!*)          % value to be edited in via build.sh
(cl:if (not (cl:integerp revision!*))
    (load!-package 'revision))
(load!-package 'rlisp)
(load!-package 'clrend)
(load!-package 'smacros)
(load!-package 'poly)
(load!-package 'arith)
(load!-package 'alg)
(load!-package 'rtools)
(load!-package 'mathpr)
(cl:let (!*msg)
   (load!-package 'entry))

(cl:fmakunbound 'prettyprint)   % otherwise defautoload has no effect!
(defautoload prettyprint pretty)  % since only in entry file for PSL!

(setq date!* (date))
(setq version!* (cl:format nil "REDUCE (Free ECL version, revision ~a)"
                            (or revision!* "???")))

(setq !*verboseload nil)        % inhibit loading messages
(setq !*redefmsg t)             % display redefinition messages

(initreduce)
(begin)
