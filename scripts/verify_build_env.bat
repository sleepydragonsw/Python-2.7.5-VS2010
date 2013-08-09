@REM Verifies that the current environment is valid for building the Python interpreter.
@REM The checks performed in this file are common to both 32-bit and 64-bit builds.
@REM Exits with %ERRORLEVEL%==0 on success and %ERRORLEVEL%==1 on failure.

@REM Ensure that perl.exe is available; it is needed to compile OpenSSL
@echo.
@echo Verifying that a valid perl.exe is present in the PATH environment variable
perl -e "use Win32;"
@if %ERRORLEVEL% NEQ 0 goto NoPerl
@echo Verifying that a valid perl.exe is present in the PATH environment variable: success

@REM Ensure that nasm.exe is available; version 2.10.1 is required
@REM See http://bugs.python.org/issue15172 for details
@echo.
@echo Verifying that a valid nasm.exe is present in the PATH environment variable
nasm -v
@if %ERRORLEVEL% NEQ 0 goto NoNasm
@echo Verifying that a valid nasm.exe is present in the PATH environment variable: success

goto done

:NoPerl
@echo off
echo.
echo ERROR: perl.exe is required in order to compile OpenSSL. >&2
echo Try installing ActivePerl (eg. ActivePerl-5.16.3.1603-MSWin32-x86) >&2
exit /b 1

:NoNasm
@echo off
echo.
echo ERROR: nasm.exe is required in order to compile OpenSSL. >&2
echo Version 2.10.1 or greater is required >&2
echo Try installing Nasm from http://www.nasm.us/pub/nasm/releasebuilds/2.10.09/win32 >&2
exit /b 1

:done
@echo.
