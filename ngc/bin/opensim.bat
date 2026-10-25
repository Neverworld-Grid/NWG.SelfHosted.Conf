@echo off
REM opensim.bat - OpenSim-NGC Tranquillity launcher for Windows
REM Adapted from bin/opensim.sh of the OpenSimulator distribution
REM Copyright (c) Contributors, http://opensimulator.org/
REM Windows adaptation (c) 2026 eva Nowicka / ENS project
REM -logconfig fix for Tranquillity based on a launcher by Gundahar Bravin
REM SPDX-License-Identifier: BSD-3-Clause
REM Full license text: LICENSE-OpenSimulator.txt

REM Tranquillity writes no logs unless told where the log configuration is.
cd /d "%~dp0"
dotnet OpenSim.dll -logconfig=OpenSim.dll.config %*
