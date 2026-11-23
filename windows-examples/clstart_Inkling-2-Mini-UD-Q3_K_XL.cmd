@echo off & setlocal enabledelayedexpansion

:INIT
set "BASE=%~dp0"
set "MODELS=%BASE%models"
set "COLI_REPO=D:\Sources\colibri"
set "COLI=%COLI_REPO%\c\coli"
set "COLI_ENGINE=%BASE%inkling.exe"
set "COLI_VULKAN=0"
set "COLI_CUDA=1"
set "COLI_GPU=0"
set "COLI_PREFIX_STORE=0"
set "CUDA_EXPERT_GB=auto"

set "MODELNAME=Inkling 2 Mini Q3_K_XL"
set "GGUF=%MODELS%\Inkling-2-Mini-UD-Q3_K_XL.gguf"
set "SNAP=%MODELS%\Inkling-2-Mini-UD-Q3_K_XL.colibri"
set "CTX=100000"

where python >nul 2>&1 || goto :NO_PY
if not exist "%COLI%"        goto :NO_COLI
if not exist "%COLI_ENGINE%" goto :NO_ENGINE
if not exist "%GGUF%"        goto :NO_MODEL

:MAIN
echo ============================================================
echo  %MODELNAME%  ^|  ctx %CTX%  ^|  engine inkling  ^|  CLI
echo  Model  : %GGUF%
echo  Import : %SNAP%
echo ============================================================
echo.
if not exist "%SNAP%" (
  echo  first run - importing the GGUF ^(metadata only, mode link^) ...
  pushd "%BASE%"
  python "%COLI%" import "%GGUF%"
  popd
  if errorlevel 1 goto :IMPORTFAIL
  echo.
)
pushd "%BASE%"
python "%COLI%" chat --model "%SNAP%" --ctx %CTX% --temp 1.0 --topp 1.0 --topk 0
popd
goto :END

:NO_PY
echo ERROR: python not found in PATH
goto :FAIL

:NO_COLI
echo ERROR: colibri launcher not found: %COLI%
echo        set COLI_REPO to the checkout that holds c\coli
goto :FAIL

:NO_ENGINE
echo ERROR: inkling engine not found: %COLI_ENGINE%
goto :FAIL

:NO_MODEL
echo ERROR: model not found: %GGUF%
goto :FAIL

:IMPORTFAIL
echo ERROR: coli import failed - see the messages above
goto :FAIL

:FAIL
echo  Press any key to close ...
pause >nul
exit /b 1

:END
endlocal
exit /b 0
