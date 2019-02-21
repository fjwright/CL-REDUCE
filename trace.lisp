;;; trace.lisp --- Standard Lisp on Common Lisp trace facilities

;; Copyright (C) 2019 Francis J. Wright

;; Author: Francis J. Wright <https://sourceforge.net/u/fjwright>
;; Created: 20 February 2019

;; Based on, and hopefully consistent with, the portable REDUCE
;; tracing code in "package/rtrace/rtrace.red".  But this is a
;; completely independent Common Lisp implementation.

(in-package :common-lisp-user)

(defpackage :standard-lisp-trace
  (:nicknames :sl-trace)
  (:documentation "Standard Lisp on Common Lisp trace facilities")
  (:use :common-lisp)
  (:export :tr :untr :trst :untrst))

(in-package :standard-lisp-trace)

;; The following macros accept a sequence of function names.  The
;; expression `(tr foo bar)' causes the input and output of the
;; functions `foo' and `bar' to be traced.  The expression `(trst foo
;; bar)' causes both the I/O and the assignments to be traced.  The
;; expression `(untr foo bar)' removes all tracing, and `untrst' is a
;; synonym for `untr'.

(defvar *traced-functions* nil
  "List of currently traced functions.")

(defmacro tr (&rest fns)
  "Trace the functions specified."
  `(cl:mapcar #'trace1 ',fns))

(defmacro untr (&rest fns)
  "Untrace(set) the functions specified.
Untrace(set) all traced functions if no functions are specified."
  `(cl:mapcar #'untrace1 ',(or fns *traced-functions*)))

(defvar *trace-setq* nil)

(defmacro trst (&rest fns)
  "Traceset the functions specified."
  `(let ((*trace-setq* t))
	 (cl:mapcar #'trace1 ',fns)))

(defmacro untrst (&rest fns)
  "Untrace(set) the functions specified.
Untrace(set) all traced functions if no functions are specified."
  `(cl:mapcar #'untrace1 ',(or fns *traced-functions*)))

(defun trace1 (name)
  "Trace or traceset function NAME.
NAME must be quoted when called!"
  (let ((defn (sl::getd name)) params sl::*redefmsg)
    (unless defn
	  (format *trace-output*
			  "***** ~a not yet defined.~%" name)
      (return-from trace1))
    (when sl::*comp
      (format *trace-output*
			  "~a ~a~%"
			  "Portable tracing does not work reliably with the"
			  "switch `comp' on, so it has been turned off.")
	  (sl::compilation (setq sl::*comp nil)))
    (if (and (sl::eqcar defn 'sl::expr) (sl::eqcar (cdr defn) 'lambda))
		;; defn = (expr lambda params body)
        (if (sl::eqcar (cadddr defn) 'run-traced-function)
            (return-from trace1
              (if (eq (get name 'traced-setq) *trace-setq*)
				  ;; i.e. both true or both false
				  (format *trace-output*
						  "*** ~a already traced.~%" name)
                  (re-trace1 name)))
			(setq params (caddr defn)))
        (progn
          (when *trace-setq*
            (format *trace-output*
					"*** ~a ~a~%~a~%"
					name
					"must be interpreted for portable assignment tracing."
					"*** Tracing arguments and return value only.")
            (setq *trace-setq* nil))
          (if (setq params (get name 'sl::number-of-args))
              (progn
                (setq params
					  (loop
						 for i from 1 upto params collect
						   (intern (make-symbol (format nil "Arg~d" i)))))
                (format *trace-output*
						"*** ~a is compiled: ~a~%"
						name
						"portable tracing may not show recursive calls."))
			  (progn
                (format *trace-output*
						"***** ~a must be interpreted for portable tracing.~%"
						name)
                (return-from trace1)))))
	(pushnew name *traced-functions*)
	(if *trace-setq*
        (progn
		  (setq defn (subst 'traced-setq 'setq defn))
		  (sl::put name 'traced-setq t))
		;; in case function has been redefined:
		(remprop name 'traced-setq))
	(sl::put name 'traced-function defn)
	(eval `(defun ,name ,params
			 (run-traced-function ',name ',params (list . ,params))))))

(defun re-trace1 (name)
  "Toggle trace/traceset for function NAME.
NAME must be quoted when called!"
  (let ((defn (get name 'traced-function)))
    (if *trace-setq*
		(progn
          (setq defn (subst 'traced-setq 'setq defn))
          (sl::put name 'traced-setq t))
		(progn
          (setq defn (subst 'setq 'traced-setq defn))
          (remprop name 'traced-setq)))
    (sl::put name 'traced-function defn)
    (format *trace-output* "*** Trace mode of ~a changed.~%" name)
    name))

(defun untrace1 (name)
  "Remove all tracing for function NAME.
NAME must be quoted when called!"
  (let ((defn (get name 'traced-function)) sl::*redefmsg)
	(remprop name 'traced-function)
    (when defn
      (setq defn (subst 'setq 'traced-setq defn))
      (sl::putd name (car defn) (cdr defn)))
    (remprop name 'traced-setq)
	(setq *traced-functions* (remove name *traced-functions*))
    name))

(defvar trace-depth 0)

(defun run-traced-function (name params args)
  (let ((trace-depth (1+ trace-depth))
		(result (cdr (get name 'traced-function))))
    (format *trace-output* "Enter (~a) ~a~%" trace-depth name)
	(loop for param in params for arg in args do
		 (format *trace-output* "   ~a:  ~a~%" param arg))
    (setq result
          (sl::errorset `(apply ,(eval result) ',args) nil nil))
    (if (or (atom result) (cdr result))	; errorp result
		(sl::error 0 sl::emsg*)
        (setq result (car result)))
	(format *trace-output* "Leave (~a) ~a = ~a~%" trace-depth name result)
    result))

(defmacro traced-setq (left right)
  "For symbolic assignments.
Must avoid evaluating the lhs of the assignment, and evaluate
the rhs only once in case of side effects (such as a gensym)."
  `(progn (format *trace-output* "~a := " ',left)
		  ,(if (sl::eqcar right 'traced-setq)
			   `(setq ,left ,right)
			   `(prog1 (prin1 (setq ,left ,right) *trace-output*)
				  (terpri *trace-output*)))))

;;; trace.lisp ends here
