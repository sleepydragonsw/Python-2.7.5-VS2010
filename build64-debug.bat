@REM Compile 64-bit Python from source

@REM Verify a valid build environment
call %~dp0scripts\verify_build_env.bat
@if %ERRORLEVEL% NEQ 0 goto BuildFailed
call %~dp0scripts\verify_build_env_64bit.bat
@if %ERRORLEVEL% NEQ 0 goto BuildFailed

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
