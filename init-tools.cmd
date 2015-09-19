::@echo off
setlocal

if "%1" == "/c" set __CLEAN_BUILD_TOOLS=1

set BUILD_TOOLS_PACKAGE_NAME=Microsoft.DotNet.BuildTools
set BUILD_TOOLS_PACKAGE_VERSION=1.0.25-prerelease-00117

:: Ensure the DIR's end in a double slash to ensure putting quotes around them doesn't mess up the command line parser
set PROJECT_DIR=%~dp0\
set PACKAGES_DIR=%PROJECT_DIR%packages\\
set NUGET_PATH=%PACKAGES_DIR%NuGet.exe

if exist "%NUGET_PATH%" goto :afternugetrestore

if not exist "%PACKAGES_DIR%" mkdir "%PACKAGES_DIR%"
powershell -NoProfile -ExecutionPolicy unrestricted -Command "$ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest 'https://www.nuget.org/nuget.exe' -OutFile '%NUGET_PATH%'"

:afternugetrestore

:cleanbuildtools

if not "%__CLEAN_BUILD_TOOLS%" == "1" goto :restorebuildtools
if exist "%PACKAGES_DIR%\%BUILD_TOOLS_PACKAGE_NAME%" rmdir /s /q "%PACKAGES_DIR%\%BUILD_TOOLS_PACKAGE_NAME%"

goto :EOF

:restorebuildtools

if "%BUILD_TOOLS_FEED%" == "" set BUILD_TOOLS_FEED=https://www.myget.org/F/dotnet-buildtools

"%NUGET_PATH%" install %BUILD_TOOLS_PACKAGE_NAME% -Version %BUILD_TOOLS_PACKAGE_VERSION% -Source %BUILD_TOOLS_FEED% -ExcludeVersion -o "%PACKAGES_DIR%" -nocache -pre

call "%PACKAGES_DIR%\%BUILD_TOOLS_PACKAGE_NAME%\lib\init-tools.cmd" "%PROJECT_DIR%" "%PACKAGES_DIR%" "%NUGET_PATH%"

goto :EOF



