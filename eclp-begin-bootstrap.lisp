;; CL syntax but SL semantics!
(in-package :sl)
(setq *redefmsg nil)                    ; default is t
(cl:defvar *argnochk t)                 ; check argument count
(cl:defvar !*msg nil)                   ; default is t
