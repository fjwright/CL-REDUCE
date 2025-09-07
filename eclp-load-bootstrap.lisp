;; Run bootstrap REDUCE on ECLP
(let (*load-verbose*)
  (pushnew :ECLP *features*)
  (ext:chdir "fasl.eclp")
  (with-open-file (input "bootstrapreduce.dat")
    (do ((file (read-line input nil) (read-line input nil)))
        ((null file))
      (load file))))
