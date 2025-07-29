;; Run bootstrap REDUCE on ECL
;; Template for "fasl.ecl/bootstrapreduce.lisp", which builds bootstrap REDUCE dynamically.
(let (*load-verbose*
      (fasl (make-pathname :directory (pathname-directory *load-truename*))))
  ;; (format t "Absolute fasl directory: ~a~%" fasl)
  (load (merge-pathnames "sl-on-cl.fasc" fasl)))

(standard-lisp)

%% (setq !*verboseload t)       % default is nil
(setq !*redefmsg nil)           % default is t
(cl:defvar !*argnochk t)        % check argument count

(load "module")        % for definition of load-package
(load "clprolo")       % initial CL specific code

% NB: revision!* is declared fluid and checked in "rlisp/rlisp.red".
(cl:defvar revision!*)          % value to be edited in via build.sh
(cl:if (not (cl:boundp 'revision!*)) (setq revision!* nil))
(load!-package 'rlisp)
(load!-package 'clrend)
(load!-package 'smacros)
(load!-package 'poly)
(load!-package 'arith)
(load!-package 'alg)
(load!-package 'rtools)
(cl:let (!*msg) (load!-package 'entry))
(load!-package 'remake)

(cl:fmakunbound 'prettyprint)   % otherwise defautoload has no effect!
(defautoload prettyprint pretty)  % since only in entry file for PSL!

(setq date!* (date))
(setq version!* (cl:format nil "Bootstrap REDUCE (Free ECL version, revision ~a)"
                            (or revision!* "???")))

(setq !*verboseload nil)        % inhibit loading messages
(setq !*redefmsg t)             % display redefinition messages

(initreduce)
(begin)
