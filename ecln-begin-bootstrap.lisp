(standard-lisp)

;; NB: revision!* is declared fluid and checked in "rlisp/rlisp.red".
(cl:defvar revision!*)          ;; value to be edited in via build.sh
(cl:if (not (cl:boundp 'revision!*)) (setq revision!* nil))
