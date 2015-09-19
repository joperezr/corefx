@echo off
setlocal

:: set build tools feed to local
set BUILD_TOOLS_FEED=C:\Users\joperezr\Desktop\repo\buildtools\bin\packages

call init-tools.cmd

:: Check if this is a netcore msbuild call
set NETCORE_MSBUILD_PATH=
set PORTABLE_TARGETS_PATH=
IF NOT "%NETCORE_BUILD%"=="" set NETCORE_MSBUILD_PATH=C:\Users\joperezr\Desktop\repo\msbuild\bin\Windows_NT\Debug-NetCore
IF NOT "%NETCORE_BUILD%"=="" set PORTABLE_TARGETS_PATH=C:\Users\joperezr\Desktop\repo\msbuild\bin\Windows_NT\Debug-NetCore\Extensions

:: Clear the 'Platform' env variable for this session,
:: as it's a per-project setting within the build, and
:: misleading value (such as 'MCD' in HP PCs) may lead
:: to build breakage (issue: #69).
set Platform=

:: Log build command line
set _buildproj=%~dp0build.proj
set _buildlog=%~dp0msbuild.log
set _buildprefix=echo
set _buildpostfix=^> "%_buildlog%"
call :build %*

:: Build
set _buildprefix=
set _buildpostfix=
call :build %*

goto :AfterBuild

:: To build in .NetCore version of msbuild, then set Env Variable NETCORE_MSBUILD_PATH to point to the folder where you have msbuild with its runtime.
:build
IF "%NETCORE_MSBUILD_PATH%"=="" %_buildprefix% msbuild "%_buildproj%" /verbosity:diag /nodeReuse:false /fileloggerparameters:Verbosity=normal;LogFile="%_buildlog%";Append %* %_buildpostfix%
IF NOT "%NETCORE_MSBUILD_PATH%"=="" %_buildprefix% "%NETCORE_MSBUILD_PATH%/CoreRun.exe" "%NETCORE_MSBUILD_PATH%/MSBuild.exe" "%_buildproj%" /verbosity:diag /p:NETCORE_MSBUILD_PATH=%NETCORE_MSBUILD_PATH%;ImportGenNugetPackageVersions=false /nodeReuse:false /fileloggerparameters:Verbosity=normal;LogFile="%_buildlog%";Append %* %_buildpostfix%
set BUILDERRORLEVEL=%ERRORLEVEL%
goto :eof

:AfterBuild

echo.
:: Pull the build summary from the log file
findstr /ir /c:".*Warning(s)" /c:".*Error(s)" /c:"Time Elapsed.*" "%_buildlog%"
echo Build Exit Code = %BUILDERRORLEVEL%

exit /b %BUILDERRORLEVEL%