@REM Compile 32-bit Python from source

@REM Ensure that we are running from a Visual Studio command prompt
if "%VCINSTALLDIR%" == "" goto NotInVisualStudioCommandPrompt

@REM Ensure that we are running from a 64-bit Visual Studio command prompt
if "%Platform%" == "x64" goto In64BitVisualStudioCommandPrompt
if "%Platform%" == "X64" goto In64BitVisualStudioCommandPrompt
goto NotIn64BitVisualStudioCommandPrompt
:In64BitVisualStudioCommandPrompt

@REM Ensure that perl.exe is available; it is needed to compile OpenSSL
perl -v >NUL
@if %ERRORLEVEL% NEQ 0 goto NoPerl

@REM Ensure that nasm.exe is available; version 2.10.1 is required
@REM See http://bugs.python.org/issue15172 for details
nasm -h >NUL
@if %ERRORLEVEL% NEQ 0 goto NoNasm

@REM Compile TCL
cd tcl8.5.14\win
@if %ERRORLEVEL% NEQ 0 goto BuildFailed
nmake -f makefile.vc COMPILERFLAGS=-DWINVER=0x0500 DEBUG=1 MACHINE=AMD64 INSTALLDIR=..\..\tcltk64 clean all
@if %ERRORLEVEL% NEQ 0 goto BuildFailed
nmake -f makefile.vc COMPILERFLAGS=-DWINVER=0x0500 DEBUG=1 MACHINE=AMD64 INSTALLDIR=..\..\tcltk64 install
@if %ERRORLEVEL% NEQ 0 goto BuildFailed
cd ..\..

@REM Compile Tk
cd tk8.5.14\win
@if %ERRORLEVEL% NEQ 0 goto BuildFailed
nmake -f makefile.vc COMPILERFLAGS=-DWINVER=0x0500 OPTS=noxp DEBUG=1 MACHINE=AMD64 INSTALLDIR=..\..\tcltk64 TCLDIR=..\..\tcl8.5.14 clean
@if %ERRORLEVEL% NEQ 0 goto BuildFailed
nmake -f makefile.vc COMPILERFLAGS=-DWINVER=0x0500 OPTS=noxp DEBUG=1 MACHINE=AMD64 INSTALLDIR=..\..\tcltk64 TCLDIR=..\..\tcl8.5.14 all
@if %ERRORLEVEL% NEQ 0 goto BuildFailed
nmake -f makefile.vc COMPILERFLAGS=-DWINVER=0x0500 OPTS=noxp DEBUG=1 MACHINE=AMD64 INSTALLDIR=..\..\tcltk64 TCLDIR=..\..\tcl8.5.14 install
@if %ERRORLEVEL% NEQ 0 goto BuildFailed
cd ..\..

@REM Compile Python
@REM For 64-bit builds, need to set HOST_PYTHON as a workaround for the way that VS invokes build_ssl.py
set HOST_PYTHON=%~dp0Python-2.7.5\PCbuild\amd64\python_d.exe
cd Python-2.7.5\PCbuild
@if %ERRORLEVEL% NEQ 0 goto BuildFailed
msbuild pcbuild.sln  /p:Configuration="Debug" /p:Platform="x64"
@if %ERRORLEVEL% NEQ 0 goto BuildFailed
amd64\python_d -c "print('If you see this line then compilation succeeded')"
@if %ERRORLEVEL% NEQ 0 goto BuildFailed
cd ..\..

goto done

:NotInVisualStudioCommandPrompt
@echo off
echo.
echo ERROR: Not running from a 64-bit Visual Studio command prompt. >&2
echo Try selecting "Visual Studio x64 Win64 Command Prompt (2010)" or >&2
echo "Visual Studio x64 Cross Tools Command Prompt (2010)" from the >&2
echo Start menu and running this command from the resulting command prompt >&2
goto BuildFailed

:NotIn64BitVisualStudioCommandPrompt
@echo off
echo.
echo ERROR: Running from a 32-bit Visual Studio command prompt, but 64-bit required. >&2
echo Try selecting "Visual Studio x64 Win64 Command Prompt (2010)" or >&2
echo "Visual Studio x64 Cross Tools Command Prompt (2010)" from the >&2
echo Start menu and running this command from the resulting command prompt >&2
goto BuildFailed

:NoPerl
@echo off
echo.
echo ERROR: perl.exe is required in order to compile OpenSSL. >&2
echo Try installing ActivePerl (eg. ActivePerl-5.16.3.1603-MSWin32-x86) >&2
goto BuildFailed

:NoNasm
@echo off
echo.
echo ERROR: nasm.exe is required in order to compile OpenSSL. >&2
echo Version 2.10.1 or greater is required >&2
echo Try installing Nasm from http://www.nasm.us/pub/nasm/releasebuilds/2.10.09/win32 >&2
goto BuildFailed

:BuildFailed
@echo off
echo.
echo BUILD FAILED!!!! >&2
exit /b 1

:done
@echo off
echo.
echo Python Successfully Built
echo Try your newly-compiled Python interpreter by running: Python-2.7.5\PCbuild\amd64\python_d.exe
