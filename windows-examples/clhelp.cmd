@echo off & setlocal enabledelayedexpansion

:INIT
set "BASE=%~dp0"
set "COLI_REPO=D:\Sources\colibri"
set "COLI=%COLI_REPO%\c\coli"

:MAIN
echo ============================================================
echo  colibri  ^|  help dump
echo ============================================================
echo.
where python >nul 2>&1 || goto :NO_PY
if not exist "%COLI%" goto :NO_COLI
pushd "%BASE%"
python "%COLI%" --help         >"colibri-help.txt"  2>&1
python "%COLI%" serve --help   >"colibri-serve.txt" 2>&1
python "%COLI%" chat --help    >"colibri-chat.txt"  2>&1
python "%COLI%" import --help  >"colibri-import.txt" 2>&1
popd
echo  written: %BASE%colibri-help.txt
echo  written: %BASE%colibri-serve.txt
echo  written: %BASE%colibri-chat.txt
echo  written: %BASE%colibri-import.txt
goto :END

:NO_PY
echo ERROR: python not found in PATH
goto :FAIL

:NO_COLI
echo ERROR: colibri launcher not found: %COLI%
echo        set COLI_REPO to the checkout that holds c\coli
goto :FAIL

:FAIL
echo  Press any key to close ...
pause >nul
exit /b 1

:END
echo.
if "%~1"=="" (echo  Press any key to close ...& pause >nul)
endlocal
exit /b 0
