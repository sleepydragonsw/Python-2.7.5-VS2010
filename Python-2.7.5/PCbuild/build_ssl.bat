@REM Make sure this script is running from the directory that contains it
cd %~dp0

@echo off
if not defined HOST_PYTHON (
  if %1 EQU Debug (
    set HOST_PYTHON=python_d.exe
    if not exist python27_d.dll exit 1
  ) ELSE (
    set HOST_PYTHON=python.exe
    if not exist python27.dll exit 1
  )
)

@REM To assist in debugging the output, echo the command that ultimately gets run
@echo on
%HOST_PYTHON% build_ssl.py %1 %2 %3
