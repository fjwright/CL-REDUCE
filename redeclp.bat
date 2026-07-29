@echo off
rem Start ECL REDUCE on Windows using portable byte-code fasl files.
rem Author: Francis J. Wright <https://sourceforge.net/u/fjwright>
rem Time-stamp: <2026-07-29 16:47:52 franc>

rem See "help call" for expansion of batch script argument references.

setlocal
rem Process args in a loop, starting with arg 0.
rem cl=%~dp0 evaluates to the common-lisp directory.
for /f %%i in ('cygpath -u "%~dp0fasl.eclp\reduce"') do set r=%%i
:loop
if "%1" equ "" goto done
if "%1" equ "-h" goto help
if "%1" equ "--help" goto help
if "%1" equ "--no-rcfile" (
  set norcfile=-- --no-rcfile
) else (
  set args=%args% %1
)
shift
goto loop
:done
set args=%args% %norcfile%
goto doit

:help
echo Start ECL REDUCE on Windows using portable byte-code fasl files.
echo Usage: redeclp ^<options^>
echo Useful options:
echo   -h, --help   Print this message and exit.
echo   --no-rcfile  Inhibit REDUCE startup file.
exit /b

:doit
ecl --norc --eval "(let (*load-verbose*) (pushnew :ECLP *features*) (load ""%r%""))" %args%

rem REDUCE options (currently only --no-rcfile) must appear after any
rem ECL options and *must* follow the option separator --.
