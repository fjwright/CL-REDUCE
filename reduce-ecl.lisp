;; Run REDUCE on ECL
;; Template for "fasl.ecl/reduce.lisp", which builds REDUCE dynamically.
(let (*load-verbose*
      (fasl (make-pathname :directory (pathname-directory *load-truename*))))
  ;; (format t "Absolute fasl directory: ~a~%" fasl)
  (load (merge-pathnames "sl-on-cl" fasl))
  (load (merge-pathnames "trace" fasl)))

(standard-lisp)

%% (setq !*verboseload t)       % default is nil
(setq !*redefmsg nil)           % default is t
(cl:defvar !*argnochk t)        % check argument count

(load "module")        % for definition of load-package
(load "clprolo")       % initial CL specific code

(load!-package 'rlisp)
(load!-package 'clrend)
(load!-package 'smacros)
(load!-package 'poly)
(load!-package 'arith)
(load!-package 'alg)
(load!-package 'rtools)
(load!-package 'mathpr)
(cl:let (!*msg) (load!-package 'entry))

(cl:fmakunbound 'prettyprint)   % otherwise defautoload has no effect!
(defautoload prettyprint pretty)  % since only in entry file for PSL!

% The following @variables are replaced using sed in buildx.sh:
(setq date!* "@date")
(setq version!* "REDUCE (revision @revision on @lispversion)")

(setq !*verboseload nil)        % inhibit loading messages
(setq !*redefmsg t)             % display redefinition messages

(initreduce)
(begin)
