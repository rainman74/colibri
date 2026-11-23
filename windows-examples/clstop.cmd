@echo off & setlocal enabledelayedexpansion

:INIT
set "BASE=%~dp0"
set "COLI_REPO=D:\Sources\colibri"
set "COLI=%COLI_REPO%\c\coli"
set "PORT=9931"
set "KILLED=0"

:MAIN
echo ============================================================
echo  Stop colibri
echo  Port: %PORT%
echo ============================================================
echo.
if not exist "%COLI%" goto :KILLENGINE
where python >nul 2>&1 || goto :KILLENGINE
echo  asking colibri to stop ...
python "%COLI%" stop >nul 2>&1
echo.

:KILLENGINE
for /f "tokens=2 delims=," %%A in ('tasklist /fi "imagename eq inkling.exe" /fo csv /nh 2^>nul') do (
  set "PID=%%~A"
  if defined PID (
    echo  inkling.exe PID !PID! stopping ...
    taskkill /f /pid !PID! >nul 2>&1
    if errorlevel 1 (
      echo    ERROR: access denied - run this script as administrator too
    ) else (
      echo    stopped
      set /a KILLED+=1
    )
    set "PID="
  )
)
echo.
call :CHECKPORT
echo.
echo GPU memory now:
where nvidia-smi >nul 2>&1 && nvidia-smi --query-gpu=memory.used,memory.free --format=csv,noheader
goto :END

:CHECKPORT
set "OCC="
for /f "tokens=1" %%X in ('netstat -ano ^| findstr /c:":%PORT% " ^| findstr /c:"0.0.0.0:0"') do set "OCC=1"
if defined OCC (
  echo  Port %PORT%: still in use
) else (
  echo  Port %PORT%: free
)
exit /b 0

:END
echo.
if "%~1"=="" (echo  Press any key to close ...& pause >nul)
endlocal
exit /b 0
