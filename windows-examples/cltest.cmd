@echo off & setlocal enabledelayedexpansion

:INIT
set "PORT=9931"
set "MODELID=llama-home"
set "QUESTION=What is 1+1?"
for /f "usebackq delims=" %%A in (`echo prompt $E^| cmd`) do set "ESC=%%A"
set "GREEN=%ESC%[32m"
set "RESET=%ESC%[0m"

:MAIN
echo ============================================================
echo  colibri  ^|  API smoke test  ^|  Port %PORT%
echo  Model  : %MODELID%
echo  Question: %QUESTION%
echo ============================================================
echo.
curl -s http://127.0.0.1:%PORT%/v1/chat/completions -H "content-type: application/json" -d "{\"model\": \"%MODELID%\", \"messages\": [{\"role\": \"user\", \"content\": \"%QUESTION%\"}], \"max_tokens\": 64}" | powershell -command "$obj = $input | ConvertFrom-Json; if (-not $obj.choices) { Write-Host '  no response - is coli serve running?'; return }; $c = $obj.choices[0].message.content; if ($c) { Write-Host ''; Write-Host '%GREEN%'$c'%RESET%' } else { Write-Host '  answer : (empty)' }"
goto :END

:END
echo.
if "%~1"=="" (echo  Press any key to close ...& pause >nul)
endlocal
exit /b 0
