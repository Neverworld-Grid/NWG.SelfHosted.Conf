@echo off
REM opensim.bat - OpenSimulator launcher for Windows
REM Adapted from bin/opensim.sh of the OpenSimulator distribution
REM Copyright (c) Contributors, http://opensimulator.org/
REM Windows adaptation (c) 2026 eva Nowicka / ENS project
REM SPDX-License-Identifier: BSD-3-Clause
REM Full license text: LICENSE-OpenSimulator.txt

cd /d "%~dp0"

REM Without the .NET runtime the simulator stops at once, with no message and
REM no log; say so instead, and keep the window open to read it.
set DOTNET_MAJOR=8
dotnet --list-runtimes 2>nul | findstr /b /c:"Microsoft.NETCore.App %DOTNET_MAJOR%." >nul || goto nodotnet

dotnet OpenSim.dll %*
goto :eof

:nodotnet
echo ERROR: the .NET %DOTNET_MAJOR% runtime (Microsoft.NETCore.App %DOTNET_MAJOR%.x) was not found.
echo Install it from https://dotnet.microsoft.com/download/dotnet/%DOTNET_MAJOR%.0 and try again.
where dotnet >nul 2>&1 && (
    echo Runtimes found on this computer:
    dotnet --list-runtimes
)
pause
exit /b 1
