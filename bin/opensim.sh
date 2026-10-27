#!/bin/sh
# opensim.sh - OpenSimulator launcher for Linux / macOS
# Adapted from bin/opensim.sh of the OpenSimulator distribution
# Copyright (c) Contributors, http://opensimulator.org/
# Changes (c) 2026 eva Nowicka / ENS project
# SPDX-License-Identifier: BSD-3-Clause
# Full license text: LICENSE-OpenSimulator.txt

cd "$(dirname "$0")" || exit 1

# Without the .NET runtime the simulator stops at once, with no message and
# no log; say so instead.
DOTNET_MAJOR=8
if ! dotnet --list-runtimes 2>/dev/null | grep -q "^Microsoft.NETCore.App $DOTNET_MAJOR\."; then
    echo "ERROR: the .NET $DOTNET_MAJOR runtime (Microsoft.NETCore.App $DOTNET_MAJOR.x) was not found." >&2
    echo "Install it from https://dotnet.microsoft.com/download/dotnet/$DOTNET_MAJOR.0 and try again." >&2
    if command -v dotnet >/dev/null 2>&1; then
        echo "Runtimes found on this computer:" >&2
        dotnet --list-runtimes >&2
    fi
    exit 1
fi

ulimit -s 1048576
exec dotnet OpenSim.dll "$@"
