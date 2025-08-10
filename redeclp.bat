@echo off
rem Start ECL REDUCE on Windows using portable byte-code fasl files.
rem See "help call" for expansion of batch script argument references.
for /f %%i in ('cygpath -u "%~dp0fasl.eclp\reduce"') do set r=%%i
ecl --eval "(let (*load-verbose*) (pushnew :ECLP *features*) (load ""%r%""))"
