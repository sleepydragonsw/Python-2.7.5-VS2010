@REM Compile 32-bit Python from source

@REM Ensure that perl.exe is available; it is needed to compile OpenSSL
perl -v >NUL
if %ERRORLEVEL% NEQ 0 goto NoPerl

@REM Ensure that nasm.exe is available; version 2.10.1 is required
@REM See http://bugs.python.org/issue15172 for details
nasm -h >NUL
if %ERRORLEVEL% NEQ 0 goto NoNasm

@REM Compile OpenSSL
cd openssl-1.0.1e
if %ERRORLEVEL% NEQ 0 exit /b 1
perl Configure --openssldir=D:\NotBackedUp\support\openssl-1.0.0e\ enable-camellia disable-idea VC-WIN32
if %ERRORLEVEL% NEQ 0 exit /b 1
call ms\do_ms.bat
if %ERRORLEVEL% NEQ 0 exit /b 1
nmake -f ms\nt.mak
if %ERRORLEVEL% NEQ 0 exit /b 1
nmake -f ms\ntdll.mak
if %ERRORLEVEL% NEQ 0 exit /b 1
cd ..

@REM Compile TCL
cd tcl8.5.14\win
if %ERRORLEVEL% NEQ 0 exit /b 1
nmake -f makefile.vc COMPILERFLAGS=-DWINVER=0x0500 DEBUG=1 INSTALLDIR=..\..\tcltk clean all
if %ERRORLEVEL% NEQ 0 exit /b 1
nmake -f makefile.vc DEBUG=1 INSTALLDIR=..\..\tcltk install
if %ERRORLEVEL% NEQ 0 exit /b 1
cd ..\..

@REM Compile Tk
cd tk8.5.14\win
if %ERRORLEVEL% NEQ 0 exit /b 1
nmake -f makefile.vc COMPILERFLAGS=-DWINVER=0x0500 OPTS=noxp DEBUG=1 INSTALLDIR=..\..\tcltk TCLDIR=..\..\tcl8.5.14 clean
if %ERRORLEVEL% NEQ 0 exit /b 1
nmake -f makefile.vc COMPILERFLAGS=-DWINVER=0x0500 OPTS=noxp DEBUG=1 INSTALLDIR=..\..\tcltk TCLDIR=..\..\tcl8.5.14 all
if %ERRORLEVEL% NEQ 0 exit /b 1
nmake -f makefile.vc COMPILERFLAGS=-DWINVER=0x0500 OPTS=noxp DEBUG=1 INSTALLDIR=..\..\tcltk TCLDIR=..\..\tcl8.5.14 install
if %ERRORLEVEL% NEQ 0 exit /b 1
cd ..\..

@REM Compile Python
cd Python-2.7.5\PCbuild
if %ERRORLEVEL% NEQ 0 exit /b 1
msbuild pcbuild.sln  /p:Configuration="Debug" /p:Platform="Win32"
if %ERRORLEVEL% NEQ 0 exit /b 1
python_d -c "print("""Build Successful!""")"
if %ERRORLEVEL% NEQ 0 exit /b 1
cd ..\..

@REM All good!
goto done

:NoPerl
echo perl.exe is required in order to compile OpenSSL
echo Try installing ActivePerl (eg. ActivePerl-5.16.3.1603-MSWin32-x86)
exit /b 1

:NoNasm
echo nasm.exe is required in order to compile OpenSSL
echo Version 2.10.1 or greater is required
echo Try installing Nasm from http://www.nasm.us/pub/nasm/releasebuilds/2.10.09/win32
exit /b 1

:done
