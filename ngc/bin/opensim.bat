@echo off
REM opensim.bat - OpenSim-NGC Tranquillity launcher for Windows
REM Adapted from bin/opensim.sh of the OpenSimulator distribution
REM Copyright (c) Contributors, http://opensimulator.org/
REM Windows adaptation (c) 2026 eva Nowicka / ENS project
REM -logconfig fix for Tranquillity based on a launcher by Gundahar Bravin
REM SPDX-License-Identifier: BSD-3-Clause
REM Full license text: LICENSE-OpenSimulator.txt

cd /d "%~dp0"

REM The configuration-only package has no simulator: say so instead of the
REM cryptic error from dotnet.
if not exist OpenSim.dll goto nosim

REM Without the .NET runtime the simulator stops at once, with no message and
REM no log; say so instead, and keep the window open to read it.
REM The version needed is in OpenSim.runtimeconfig.json ("version": "8.0.0").
set DOTNET_MAJOR=8
for /f "tokens=2 delims=:." %%v in ('findstr /c:"\"version\"" OpenSim.runtimeconfig.json 2^>nul') do set DOTNET_MAJOR=%%v
set DOTNET_MAJOR=%DOTNET_MAJOR: =%
set DOTNET_MAJOR=%DOTNET_MAJOR:"=%
where dotnet >nul 2>&1 || goto nodotnet
dotnet --list-runtimes 2>nul | findstr /b /c:"Microsoft.NETCore.App %DOTNET_MAJOR%." >nul || goto nodotnet

REM Tranquillity writes no logs unless told where the log configuration is.
dotnet OpenSim.dll -logconfig=OpenSim.dll.config %*
REM If the simulator stopped with an error, keep the window open to read it.
set RC=%errorlevel%
if not "%RC%"=="0" pause
exit /b %RC%

:nosim
echo ERROR: OpenSim.dll was not found in this folder (%CD%).
echo This launcher must be in the bin folder of an OpenSimulator installation.
echo If you downloaded only the configuration package, download the full
echo package instead, or copy these files into your OpenSimulator bin folder.
pause
exit /b 1

:nodotnet
echo ERROR: the .NET %DOTNET_MAJOR% runtime (Microsoft.NETCore.App %DOTNET_MAJOR%.x) was not found.
echo Install it from https://dotnet.microsoft.com/download/dotnet/%DOTNET_MAJOR%.0 and try again.
where dotnet >nul 2>&1 && (
    echo Runtimes found on this computer:
    dotnet --list-runtimes
)
pause
exit /b 1
