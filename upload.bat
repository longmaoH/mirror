@echo off
echo ========================================
echo NuGet包批量下载工具
echo 开始时间: %date% %time%
echo ========================================
setlocal enabledelayedexpansion

REM ============ 配置区域 ============
set "TARGET_DIR=local-nuget-packages"
set "TEMP_DIR=temp-nuget-download"
set "DOTNET_EXE=C:\Program Files\dotnet\dotnet.exe"

REM 检查dotnet是否安装
if not exist "%DOTNET_EXE%" (
    echo [错误] 未找到dotnet.exe，请确保已安装.NET Core SDK
    echo 下载地址: https://dotnet.microsoft.com/download/dotnet-core/2.2
    pause
    exit /b 1
)

REM ============ 包定义 ============
set "pkg_count=42"
set "pkg_list[0]=Microsoft.Extensions.Options.ConfigurationExtensions 2.2.0"
set "pkg_list[1]=Swashbuckle.AspNetCore 4.0.1"
set "pkg_list[2]=System.Net.Primitives 4.3.1"
set "pkg_list[3]=System.Net.NameResolution 4.3.0"
set "pkg_list[4]=Castle.LoggingFacility.MsLogging 3.1.0"
set "pkg_list[5]=Microsoft.AspNetCore.Diagnostics 2.2.0"
set "pkg_list[6]=Microsoft.AspNetCore.Diagnostics.EntityFrameworkCore 2.2.1"
set "pkg_list[7]=Microsoft.AspNetCore.Mvc 2.2.0"
set "pkg_list[8]=Microsoft.AspNetCore.Server.IISIntegration 2.2.1"
set "pkg_list[9]=Microsoft.AspNetCore.Server.Kestrel 2.2.0"
set "pkg_list[10]=Microsoft.AspNetCore.StaticFiles 2.2.0"
set "pkg_list[11]=Microsoft.EntityFrameworkCore.SqlServer 2.2.4"
set "pkg_list[12]=Microsoft.EntityFrameworkCore.SqlServer.Design 1.1.6"
set "pkg_list[13]=Microsoft.Extensions.Logging 2.2.0"
set "pkg_list[14]=Microsoft.VisualStudio.Web.BrowserLink 2.2.0"
set "pkg_list[15]=Microsoft.VisualStudio.Web.CodeGeneration.Design 2.2.3"
set "pkg_list[16]=Microsoft.EntityFrameworkCore.Tools 2.2.4"
set "pkg_list[17]=Castle.Core 4.4.0"
set "pkg_list[18]=Abp.AspNetCore 4.8.1"
set "pkg_list[19]=Abp.Castle.Log4Net 4.8.1"
set "pkg_list[20]=Abp.EntityFrameworkCore 4.8.1"
set "pkg_list[21]=Microsoft.AspNetCore.Http 2.2.2"
set "pkg_list[22]=MySql.Data 8.0.17"
set "pkg_list[23]=MySql.Data.EntityFrameworkCore 8.0.17"
set "pkg_list[24]=MySql.Data.EntityFrameworkCore.Design 8.0.17"
set "pkg_list[25]=NPOI 2.4.1"
set "pkg_list[26]=SharpZipLib 1.2.0"
set "pkg_list[27]=System.Data.Common 4.3.0"
set "pkg_list[28]=Abp 4.8.1"
set "pkg_list[29]=Abp.AutoMapper 4.8.1"
set "pkg_list[30]=Abp.Web.Common 4.8.1"
set "pkg_list[31]=Microsoft.Extensions.Configuration.EnvironmentVariables 2.2.4"
set "pkg_list[32]=Microsoft.Extensions.Configuration.Json 2.2.0"
set "pkg_list[33]=DocumentFormat.OpenXml 2.9.1"
set "pkg_list[34]=EPPlus.Core 1.5.4"
set "pkg_list[35]=Microsoft.AspNetCore.Hosting 2.2.0"
set "pkg_list[36]=Microsoft.AspNetCore.Mvc.Core 2.2.5"
set "pkg_list[37]=Newtonsoft.Json 12.0.2"
set "pkg_list[38]=System.Threading.Tasks 4.3.0"
set "pkg_list[39]=Castle.Facilities.Logging 5.0.0"  REM 替代包
set "pkg_list[40]=Pomelo.EntityFrameworkCore.MySql 3.2.0"  REM MySQL替代包
set "pkg_list[41]=EPPlus 4.5.3.3"  REM EPPlus替代包

REM ============ 创建目录 ============
echo [1/4] 准备目录结构...
if exist "%TARGET_DIR%" (
    echo 目标目录已存在，清空内容...
    rmdir /s /q "%TARGET_DIR%"
)
mkdir "%TARGET_DIR%"

if exist "%TEMP_DIR%" (
    rmdir /s /q "%TEMP_DIR%"
)
mkdir "%TEMP_DIR%"

REM ============ 创建临时项目 ============
echo [2/4] 创建临时项目...
cd "%TEMP_DIR%"
"%DOTNET_EXE%" new console -n TempProj --force
cd TempProj

REM ============ 下载所有包 ============
echo [3/4] 开始下载%pkg_count%个NuGet包...
echo 预计需要2-5分钟，请耐心等待...
echo.

set "success_count=0"
set "fail_count=0"
set "start_time=%time%"

for /l %%i in (0,1,41) do (
    for /f "tokens=1,2" %%a in ("!pkg_list[%%i]!") do (
        set "pkg_name=%%a"
        set "pkg_version=%%b"
    )
    
    echo [!time!] 正在下载 [!pkg_count!/%%i]: !pkg_name! !pkg_version!
    
    "%DOTNET_EXE%" add package !pkg_name! --version !pkg_version! --no-restore >nul 2>&1
    
    if !errorlevel! equ 0 (
        echo     成功
        set /a success_count+=1
    ) else (
        echo     [失败] 请检查包名和版本
        set /a fail_count+=1
        echo !pkg_name! !pkg_version! >> ..\..\failed-packages.txt
    )
)

REM ============ 还原包到目标目录 ============
echo.
echo [4/4] 还原包文件到 %TARGET_DIR% ...
"%DOTNET_EXE%" restore --packages ..\..\%TARGET_DIR% --verbosity quiet

REM ============ 清理和统计 ============
cd ..\..
rmdir /s /q "%TEMP_DIR%"

set "end_time=%time%"

echo.
echo ========================================
echo 下载完成!
echo ========================================
echo 开始时间: %start_time%
echo 结束时间: %end_time%
echo 总包数:   %pkg_count%
echo 成功:     %success_count%
echo 失败:     %fail_count%
echo 目标目录: %cd%\%TARGET_DIR%
echo.

if exist failed-packages.txt (
    echo 以下包下载失败，请手动处理:
    type failed-packages.txt
    echo.
    echo 建议操作:
    echo 1. Castle.LoggingFacility.MsLogging - 尝试使用 Castle.Facilities.Logging
    echo 2. MySql.Data.EntityFrameworkCore - 已自动替换为 Pomelo.EntityFrameworkCore.MySql
    echo 3. EPPlus.Core - 已自动替换为 EPPlus
    echo.
)

echo 包目录结构示例:
echo %TARGET_DIR%\
echo   └─ castle.core\
echo        └─ 4.4.0\
echo            ├─ castle.core.4.4.0.nupkg
echo            └─ (其他文件)
echo.

echo 下一步操作建议:
echo 1. 检查 %TARGET_DIR% 目录确认所有包已下载
echo 2. 上传到你的私有NuGet镜像服务器
echo 3. 更新项目的nuget.config指向你的私有源
echo.

echo 按任意键打开目标目录...
pause >nul
start "" "%TARGET_DIR%"