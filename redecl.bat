@echo off
rem Start ECL REDUCE on Windows.
rem See "help call" for expansion of batch script argument references.
rem sbcl --noinform  --core %~dp0fasl.sbcl\reduce.img
ecl --eval "(let (*load-verbose*) (load ""reduce""))"
rem But not currently relocatable!
