@echo off
rem Start the Windows SBCL REDUCE image
rem start "SBCL REDUCE" sbcl --noinform  --core fasl/reduce.img --eval (start-reduce)
sbcl --noinform  --core fasl/reduce.img --eval (start-reduce)
