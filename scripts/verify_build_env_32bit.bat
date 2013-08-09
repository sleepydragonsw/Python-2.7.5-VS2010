@REM Verifies that the current environment is valid for building a 32-bit Python interpreter.
@REM The checks performed in this file only apply to 32-bit builds (ie. not 64-bit builds)
@REM Exits with %ERRORLEVEL%==0 on success and %ERRORLEVEL%==1 on failure.

@REM Ensure that we are running from a Visual Studio command prompt
@echo.
@echo Verifying that we are running from a Visual Studio command prompt
if "%VCINSTALLDIR%" == "" goto NotInVisualStudioCommandPrompt
@echo Verifying that we are running from a Visual Studio command prompt: success

@REM Ensure that we are running from a 32-bit Visual Studio command prompt
@echo.
@echo Verifying that we are running from a 32-bit Visual Studio command prompt
if not "%Platform%" == "" goto NotIn32BitVisualStudioCommandPrompt
@echo Verifying that we are running from a 32-bit Visual Studio command prompt

goto done

:NotInVisualStudioCommandPrompt
@echo off
echo.
echo ERROR: Not running from a 32-bit Visual Studio command prompt. >&2
echo Try selecting "Visual Studio Command Prompt (2010)" from the >&2
echo Start menu and running this command from the resulting command prompt >&2
exit /b 1

:NotIn32BitVisualStudioCommandPrompt
@echo off
echo.
echo ERROR: Running from a 64-bit Visual Studio command prompt, but 32-bit required. >&2
echo Try selecting "Visual Studio Command Prompt (2010)" from the >&2
echo Start menu and running this command from the resulting command prompt >&2
exit /b 1

:done
@echo.
