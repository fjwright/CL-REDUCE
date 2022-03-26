;; Common Lisp code to build a bootstrap version of REDUCE on Common Lisp.
;; Based on "psl/bootstrap.sh".

;; Author: Francis J. Wright <https://sourceforge.net/u/fjwright>
;; Created: 24 March 2022

;; Build an initial bootstrap REDUCE image without fasl files, which
;; does not form part of the final REDUCE system and should not need to
;; be rebuilt very often.  It is used (by build.sh) to compile REDUCE.
;; Assume this code is run in the top-level CL REDUCE directory.

;; Supports Steel Bank Common Lisp (SBCL), CLISP and Armed Bear Common
;; Lisp (ABCL).

;; This file compiles sl-on-cl, loads it and builds a bootstrap REDUCE
;; image, and then terminates Lisp.

(defconstant lisp
  #+SBCL "sbcl"
  #+CLISP "clisp"
  #+ABCL "abcl"
  "Common Lisp implementation in use")

(defconstant faslext
  #+SBCL "fasl"
  #+CLISP "fas"
  #+ABCL "abcl"
  "Filename extension of a compiled Lisp file")

(ensure-directories-exist (format nil "log.~A/" lisp))
(ensure-directories-exist (format nil "fasl.~A/" lisp))

(let ((fasl (format nil "sl-on-cl.~A" faslext)))
  (unless (and (probe-file fasl)
               (> (file-write-date fasl) (file-write-date "sl-on-cl.lisp")))
    (format t "~%+++++ Compiling sl-on-cl~2%")
    (unless
        (with-open-file (*standard-output*
                         (format nil "log.~A/sl-on-cl.blg" lisp)
                         :direction :output :if-exists :supersede)
          (compile-file "sl-on-cl"))       ; &> log.$lisp/sl-on-cl.blg ???
      (format t "~%***** Compilation failed~%")
      #+SBCL (sb-ext:exit :code 1)
      #+CLISP (ext:exit 1)
      #+ABCL (ext:exit :status 1))
    ))

(format t "~%+++++ Building bootstrap REDUCE~2%")
(with-open-file (*standard-output*
                 (format nil "log.~A/bootstrap.blg" lisp)
                 :direction :output :if-exists :supersede)
  (load "bootstrap"))                   ; &> log.$lisp/bootstrap.blg ???
