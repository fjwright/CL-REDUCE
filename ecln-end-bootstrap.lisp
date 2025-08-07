(setq date!* (date))  % needed?
(setq version!* (cl:format nil "Bootstrap REDUCE (Free ECL version, revision ~a)"
                           (or revision!* "???")))

(setq !*verboseload nil)        % inhibit loading messages
(setq !*redefmsg t)             % display redefinition messages

(initreduce)
(begin)
