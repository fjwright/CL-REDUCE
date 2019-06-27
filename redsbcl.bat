@echo off
rem Start the Windows SBCL REDUCE image
rem start "SBCL REDUCE" sbcl --noinform  --core fasl/reduce.img --eval (start-reduce)
rem See "help call" for expansion of batch script argument references.
sbcl --noinform  --core %~dp0/fasl/reduce.img --eval (start-reduce)
