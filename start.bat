@echo off
setlocal EnableExtensions

chcp 65001 >nul
cd /d "%~dp0"

set "VENV_DIR=.venv"
set "PYTHON_EXE=%VENV_DIR%\Scripts\python.exe"
set "PORT=8033"
set "HOST=0.0.0.0"
set "BROWSER_URL=http://127.0.0.1:%PORT%"

echo [1/5] 检查 Python 虚拟环境...
if exist "%PYTHON_EXE%" goto install_deps

where py >nul 2>nul
if not errorlevel 1 (
    echo 未检测到现有虚拟环境，正在创建 %VENV_DIR% ...
    py -3 -m venv "%VENV_DIR%"
    if errorlevel 1 goto create_venv_failed
    goto install_deps
)

where python >nul 2>nul
if not errorlevel 1 (
    echo 未检测到现有虚拟环境，正在创建 %VENV_DIR% ...
    python -m venv "%VENV_DIR%"
    if errorlevel 1 goto create_venv_failed
    goto install_deps
)

echo 未找到可用的 Python，请先安装 Python 3.12+ 并勾选 Add to PATH。
goto fail

:install_deps
set "PYTHON_EXE=%VENV_DIR%\Scripts\python.exe"

echo [2/5] 升级 pip...
call "%PYTHON_EXE%" -m pip install --upgrade pip
if errorlevel 1 goto fail

echo [3/5] 安装项目依赖...
call "%PYTHON_EXE%" -m pip install -r requirements.txt
if errorlevel 1 goto fail

echo [4/5] 安装 Playwright Chromium...
call "%PYTHON_EXE%" -m playwright install chromium
if errorlevel 1 goto fail

echo [5/5] 启动服务...
echo 浏览器地址: %BROWSER_URL%
start "" "%BROWSER_URL%"
set "PORT=%PORT%"
set "HOST=%HOST%"
call "%PYTHON_EXE%" app.py
set "EXIT_CODE=%ERRORLEVEL%"

if "%EXIT_CODE%"=="0" exit /b 0

echo.
echo 服务已退出，返回码: %EXIT_CODE%
pause
exit /b %EXIT_CODE%

:create_venv_failed
echo 创建虚拟环境失败，请确认 Python 版本为 3.12+。
goto fail

:fail
echo.
echo 启动失败，请检查上方日志后重试。
pause
exit /b 1