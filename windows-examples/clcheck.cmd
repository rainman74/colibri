@echo off & setlocal enabledelayedexpansion

:INIT
set "BASE=%~dp0"
set "PORT=9931"

:MAIN
echo ============================================================
echo  colibri  ^|  memory, GPU and runtime status
echo ============================================================
echo.
echo [python]
where python >nul 2>&1 && (for /f "delims=" %%P in ('where python') do echo   %%P) || echo   not found in PATH
echo.
echo [engine processes]
powershell -Command "$p = Get-Process inkling,colibri,glm53,qwen36,qwen38,mimo,kimi_k3 -ErrorAction SilentlyContinue; if($p) { $p | Sort-Object ProcessName | ForEach-Object { Write-Host ('  ' + $_.ProcessName + '  PID ' + $_.Id + '  ' + [math]::Round($_.WorkingSet64/1GB,2) + ' GB') } } else { Write-Host '  none' }"
echo.
echo [RAM usage]
powershell -Command "$p = Get-Process inkling -ErrorAction SilentlyContinue; if($p) { $ws = [math]::Round(($p | Measure-Object WorkingSet64 -Sum).Sum / 1GB, 2); Write-Host 'inkling engine uses: ' $ws ' GB physical RAM' } else { Write-Host 'no inkling engine running.' }"
echo.
echo [VRAM]
nvidia-smi --query-gpu=memory.total,memory.used,memory.free --format=csv,noheader,nounits | powershell -Command "$in = $input | Out-String; $a = $in.Split(','); Write-Host ('Total: ' + $a[0].Trim() + ' MB | Used: ' + $a[1].Trim() + ' MB | Free: ' + $a[2].Trim() + ' MB')"
echo.
echo [API on port %PORT%]
powershell -Command "try { $r = Invoke-WebRequest -Uri 'http://127.0.0.1:%PORT%/v1/models' -TimeoutSec 4 -UseBasicParsing; Write-Host ('  responding: HTTP ' + $r.StatusCode) } catch { Write-Host '  not responding' }"
goto :END

:END
echo.
if "%~1"=="" (echo  Press any key to close ...& pause >nul)
endlocal
exit /b 0
