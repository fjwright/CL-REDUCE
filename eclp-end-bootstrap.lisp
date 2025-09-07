;; CL syntax but SL semantics!
(in-package :sl)
(setq date* (date))
(setq version* (cl:format nil "Bootstrap REDUCE (Free ECL version, revision ~a)"
                           (or revision* "???")))

(setq *verboseload nil)                ; inhibit loading messages
(setq *msg t)                          ; display messages
(setq *redefmsg t)                     ; display redefinition messages

(initreduce)
(begin)
