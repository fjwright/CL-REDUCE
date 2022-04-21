;; sl-on-cl.asd -*-Lisp-*-

;; Put this file and "sl-on-cl.lisp" in "./common-lisp/",
;; start Common Lisp and then evaluate
;; (require "asdf")

;; The default directory used by ASDF is "~/common-lisp/sl-on-cl/",
;; but to process .asd files in the current directory only run this form:

;; (asdf:initialize-source-registry `(:source-registry (:directory ,*default-pathname-defaults*) :ignore-inherited-configuration))

;; (asdf:load-system :sl-on-cl)
;; loads "sl-on-cl", compiling it first if necessary. Then (say)
;; (standard-lisp)
;; works!

;; The Cygwin CLISP binary distribution seems not to include ASDF.

;; SBCL complains about defconstant if sl-on-cl is compiled and loaded
;; in the same session (known problem, see manual), whereas CLISP (on
;; Linux) does not.

(defsystem "sl-on-cl"
    :components ((:file "sl-on-cl")))

;; Fasl files go by default to the value of asdf::*user-cache*.
;; To send them to this directory instead run this form:

(asdf:initialize-output-translations
 `(:output-translations
   :ignore-inherited-configuration
   :disable-cache
   (t ,*default-pathname-defaults*)))
