#!/bin/sh
# opensim.sh - OpenSimulator launcher for Linux / macOS
# Adapted from bin/opensim.sh of the OpenSimulator distribution
# Copyright (c) Contributors, http://opensimulator.org/
# Changes (c) 2026 eva Nowicka / ENS project
# SPDX-License-Identifier: BSD-3-Clause
# Full license text: LICENSE-OpenSimulator.txt

cd "$(dirname "$0")" || exit 1

# The configuration-only package has no simulator: say so instead of the
# cryptic error from dotnet.
if [ ! -e OpenSim.dll ]; then
    echo "ERROR: OpenSim.dll was not found in this folder ($(pwd))." >&2
    echo "This launcher must be in the bin folder of an OpenSimulator installation." >&2
    echo "If you downloaded only the configuration package, download the full" >&2
    echo "package instead, or copy these files into your OpenSimulator bin folder." >&2
    exit 1
fi

# Without the .NET runtime the simulator stops at once, with no message and
# no log; say so instead. The version needed is in OpenSim.runtimeconfig.json.
DOTNET_MAJOR=$(sed -n 's/.*"version": *"\([0-9]*\)\..*/\1/p' OpenSim.runtimeconfig.json 2>/dev/null | head -n 1)
[ -n "$DOTNET_MAJOR" ] || DOTNET_MAJOR=8
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
