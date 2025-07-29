@echo off
rem Start ECL REDUCE on Windows.
rem See "help call" for expansion of batch script argument references.
for /f %%i in ('cygpath -u "%~dp0fasl.ecl\reduce"') do set r=%%i
ecl --eval "(let (*load-verbose*) (load ""%r%""))"
