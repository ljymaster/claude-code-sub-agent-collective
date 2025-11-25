@echo off
REM 快速安装脚本 - Windows 版本

setlocal enabledelayedexpansion

echo ============================================
echo    Claude Code Collective - 快速安装
echo ============================================
echo.

REM 获取脚本所在目录
set "SCRIPT_DIR=%~dp0"
set "PROJECT_ROOT=%SCRIPT_DIR%.."

REM 设置目标目录
if "%1"=="" (
    set "TARGET_DIR=%CD%"
) else (
    set "TARGET_DIR=%1"
)

echo [目标目录] %TARGET_DIR%
echo.

REM 打包
echo [步骤 1/3] 创建安装包...
cd /d "%PROJECT_ROOT%"
for /f "delims=" %%i in ('npm pack 2^>nul') do set "PACKAGE_FILE=%%i"
echo [成功] 创建: %PACKAGE_FILE%
echo.

REM 安装
echo [步骤 2/3] 执行安装...
cd /d "%TARGET_DIR%"
npx "%PROJECT_ROOT%\%PACKAGE_FILE%" init --yes --platform=qoder
echo.

REM 验证
echo [步骤 3/3] 验证安装...
npx "%PROJECT_ROOT%\%PACKAGE_FILE%" status
echo.

echo ============================================
echo [完成] 安装成功！
echo ============================================
echo.
echo [提示] 运行以下命令进行详细验证:
echo    npx "%PROJECT_ROOT%\%PACKAGE_FILE%" validate
echo.

endlocal
