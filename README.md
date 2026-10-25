# NWG.SelfHosted.Conf

Configuration files to connect a self-hosted OpenSimulator region to the **Neverworld grid**.

## What is this

If you want to run your own OpenSimulator region and have it appear on the Neverworld grid,
you need a few configuration files that differ from a standalone setup. This repository
provides those files along with a step-by-step setup guide.

Neverworld's own page on self-hosting, with the application form, is
[Self-host regions on Neverworld Grid](https://neverworldgrid.com/self-host-regions-on-neverworld-grid/).

## Requirements

- .NET 8.0 runtime for your operating system
- On Linux / macOS: `libgdiplus` and related libraries
- An account on the Neverworld grid and an **approved self-hosting application**
  (see [Before you start](#before-you-start-apply))
- A computer that can stay on while the region runs
- A public IP address or FQDN. On a home connection your IP changes, so use a
  free dynamic DNS name (for example No-IP or DuckDNS) and give that name in
  your application
- Ports open in your firewall / router: the simulator's port (TCP) and one port
  per region (UDP). With a single region both can be the same, `9000` by default

Tested with **OpenSimulator 0.9.3.1 Dev** (build `reb01e50`, 2026-10-22) and
**OpenSim-NGC Tranquillity 0.9.3.9333**, with both standard regions and
var-regions.

### Which version should I use?

The package comes in two flavours, both tested with this configuration:

- **OpenSim-NGC Tranquillity 0.9.3.9333** — the version Neverworld runs on its
  own regions. Choose it if you want your region to behave exactly like the rest
  of the grid. It no longer receives updates (July 2025), so it lacks the later
  OpenSimulator fixes, and it needs the launchers in `ngc/bin/` to write logs
  (and, on Linux / macOS, to find its SQLite library).
- **OpenSimulator 0.9.3.1** (official) — actively maintained: newer fixes
  (including security and robustness improvements), new LSL functions and newer
  voice support. Its behaviour can differ in small ways from the grid's own
  regions.

Before choosing or switching: the two are not interchangeable. Script states
are not carried between them, and their region databases (`OpenSim.db`)
differ. To switch, save an OAR of each region, install the other flavour from
scratch and load the OAR there; never copy `OpenSim.db` across. Every script
then restarts from its initial state.

## Setup

### Before you start: apply

Self-hosted regions must be registered before they can connect. Fill in the
[Self-Hosting Application Form](https://neverworldgrid.com/self-hosting-application-form/)
(you must be logged in to your Neverworld account on the website to see it).
You can prepare everything below meanwhile, but **start the region only after
you receive the approval email**.

### 1. Get OpenSimulator with the Neverworld configuration

There are two ways:

- **Full package** (recommended): OpenSimulator with the Neverworld
  configuration already in place, available from this repository's
  [Releases](../../releases). Extract it to a folder of your choice.
  Nothing else to copy: go on to step 2.
- **Configuration only** (this repository): if you already have OpenSimulator,
  or prefer to download the official release yourself from the OpenSimulator
  GitHub repository, extract it and copy the files from this repository's
  `bin/` folder into the `bin/` folder of your installation, replacing any
  existing files with the same name:
  - `OpenSim.ini`
  - `opensim.bat` (Windows launcher)
  - `config-include/FlotsamCache.ini`
  - `config-include/GridCommon.ini`
  - `config-include/osslEnable.ini`

  **OpenSim-NGC Tranquillity only:** then also copy the two launchers in
  `ngc/bin/` (`opensim.bat` and `opensim.sh`) into the same `bin/` folder.
  Tranquillity writes no logs unless it is told where its log configuration is;
  these launchers start it with `-logconfig=OpenSim.dll.config`. On Linux /
  macOS, make the script executable: `chmod +x opensim.sh`.
  On Linux / macOS, `opensim.sh` also fixes a Tranquillity packaging problem:
  its SQLite library sits in `bin/runtimes/`, where .NET does not look, and the
  region would stop with *Unable to load shared library 'SQLite.Interop.dll'*.
  On the first start the launcher copies it into `bin/`.

#### Configuration only, step by step

**Downloads** (pick one simulator; see [Which version should I use?](#which-version-should-i-use)):

| Simulator | Where | File |
|---|---|---|
| OpenSimulator (official) | [OpenSimulator releases](https://github.com/opensim/opensim/releases) — the tested build listed above | `LastDotNetBuild.zip` |
| OpenSim-NGC Tranquillity 0.9.3.9333 | [Tranquillity 0.9.3.9333 release](https://github.com/OpenSim-NGC/OpenSim-Tranquillity/releases/tag/tranquillity-0.9.3.9333) | `opensim-rel-0.9.3.9333.tar.gz` |
| Neverworld configuration | this repository's [Releases](../../releases) (configuration package), or *Code → Download ZIP* | `.zip` or `.tar.gz` |

The official `LastDotNetBuild.zip` contains a `bin/` folder. The Tranquillity
archive does not: its files are at the top level, so extract it into a `bin/`
folder you create.

**Linux / macOS**

```
mkdir -p ~/opensim && cd ~/opensim
# Official: download LastDotNetBuild.zip from the releases page, then
unzip LastDotNetBuild.zip
# ...or Tranquillity:
mkdir bin
wget https://github.com/OpenSim-NGC/OpenSim-Tranquillity/releases/download/tranquillity-0.9.3.9333/opensim-rel-0.9.3.9333.tar.gz
tar xzf opensim-rel-0.9.3.9333.tar.gz -C bin
```

(No `unzip`? Install it, or use `python3 -m zipfile -e LastDotNetBuild.zip .`)

Unpack the Neverworld configuration package in your home folder (it creates
`~/NWG.SelfHosted.Conf`), then copy it over the simulator's `bin/`:

```
cd ~
tar xzf NWG.SelfHosted.Conf-<date>.tar.gz
cp -r ~/NWG.SelfHosted.Conf/bin/. ~/opensim/bin/
# Tranquillity only:
cp -r ~/NWG.SelfHosted.Conf/ngc/bin/. ~/opensim/bin/
chmod +x ~/opensim/bin/opensim.sh
```

**Windows**

1. Download the simulator file and the Neverworld configuration package
   (`.zip`) with your browser.
2. Official: right-click `LastDotNetBuild.zip` → *Extract All…*.
   Tranquillity: create a `bin` folder and extract the `.tar.gz` into it, with
   7-Zip or in a terminal: `tar -xzf opensim-rel-0.9.3.9333.tar.gz -C bin`.
3. Extract the configuration package and copy the contents of its `bin` folder
   into the simulator's `bin` folder, replacing existing files. Tranquillity
   only: then copy the contents of `ngc\bin` there too.

Then go on to step 2.

### 2. Configure your region

Create a `Regions/Region.ini` file (or let OpenSim generate it on first launch
by answering the console prompts). The distribution includes
`Regions/Regions.ini.example`, with every setting explained: copy it to
`Regions/Region.ini` and review it. Both standard regions and var-regions work;
for a var-region, set `SizeX` and `SizeY` (multiples of 256). You will need:

| Setting | Value |
|---|---|
| Region name | Your chosen name (unique on the grid) |
| Region UUID | A new UUID — generate one at [uuidgenerator.net](https://www.uuidgenerator.net) |
| Grid coordinates | A free spot you choose on the [Neverworld Quick Map](https://neverworldgrid.com/neverworld-quick-map/) |
| InternalAddress | `0.0.0.0` |
| InternalPort | The region's UDP port (e.g. `9000`), different for each region |
| ExternalHostName | The public address or hostname you gave in your application. When the console asks for it on first launch, type it in; do not accept the suggested value |

**Ports.** The simulator listens on `http_listener_port` (in the `[Network]`
section of `OpenSim.ini`) over **TCP**; each region listens on its own
`InternalPort` over **UDP**. A simulator can run several regions, so:

- **One region:** the simplest is to use the same number for both (the package
  uses `9000`) and open that port for TCP and UDP.
- **Several regions:** give each region its own `InternalPort` (e.g. `9001`,
  `9002`…) and open them for UDP; open `http_listener_port` for TCP. Only one
  region can share its number with the simulator port.

**Your hostname in `OpenSim.ini`.** In the `[Network]` section, replace
`YOUR.PUBLIC.HOSTNAME` in `ExternalHostNameForLSL` with your public IP or FQDN
(the same value as `ExternalHostName`). Scripts that use HTTP-in
(`llRequestURL`) build their URLs from it; until you set it, HTTP-in stays
disabled.

### 3. Launch

- **Windows:** run `.\opensim.bat`
- **Linux / macOS:** run `./opensim.sh`

On first launch OpenSim will ask a few questions if `Region.ini` does not exist yet.

Start the region once your application has been approved; it then appears on
Neverworld.

### Keeping your approval

The approval lasts while the region is in use. A region server that stays
offline for 60 days is removed from the list; to come back after a long break,
ask the Neverworld administrators to reactivate it (see [Contact](#contact)).

To rename a region or add one, edit `Regions/*.ini` and restart; let the
Neverworld administrators know, so their records stay up to date.

## Grid settings and your own settings

The values in this package are the ones known to work for connecting to
Neverworld. They fall into three groups:

- **Grid connection — leave as they are** unless the Neverworld administrators
  tell you otherwise. The whole connection is defined once, in the `[Const]`
  section of `OpenSim.ini`: the grid hostname (`BaseHostname`) and its ports
  (`PublicPort` 8002, `PrivatePort` 8003). Every grid address elsewhere
  (`config-include/GridCommon.ini`, `[Groups]`, `[UserProfiles]`…) is built
  from those variables as `${Const|...}`; keep it that way rather than typing
  addresses in. The `[Architecture]` include also stays as it is.
- **Yours to fill in:** your region files (`Regions/*.ini`), the ports, and
  `ExternalHostNameForLSL` (see [Configure your region](#2-configure-your-region)).
- **Yours to adapt** to what you want to do on your region: OSSL permissions
  (`config-include/osslEnable.ini`), the asset cache
  (`config-include/FlotsamCache.ini`), physics, scripting, permissions and the
  rest of `OpenSim.ini`. Read the comments next to each setting and the
  [OpenSimulator wiki](http://opensimulator.org/wiki/Configuration) before
  changing them. For OSSL in particular, which functions to allow and to whom
  depends entirely on what your scripts need; see
  [OSSL Enabling Functions](http://opensimulator.org/wiki/OSSL_Enabling_Functions).
  Keep the [Security](#security) defaults unless you know why you are changing
  them.

## Updating an existing installation

1. **Back up first.** In the OpenSim console run `save oar <file>.oar` for each
   region, then stop the simulator with `shutdown` (do not just close the window).
2. Rename the current folder, e.g. `opensim` → `opensim.old`, and extract the
   new release into a fresh `opensim` folder.
3. Copy these from `opensim.old/bin/` into `opensim/bin/`:

   | File / folder | Why |
   |---|---|
   | `OpenSim.ini` | Your simulator settings |
   | `config-include/FlotsamCache.ini`, `osslEnable.ini` | Cache and OSSL settings |
   | `Regions/*.ini` | Your region definitions |
   | `OpenSim.db` | Region contents: objects, terrain, estate (SQLite). With OpenSim-NGC Tranquillity the file is named `OpenSim.db,version=3,UseUTF16Encoding=True` |
   | `ScriptEngines/` | Script states (optional; without it scripts restart fresh) |
   | `assetcache/` | Asset cache (optional; avoids downloading everything again) |
   | `OpenSimConsoleHistory.txt` | Console command history (optional) |
   | `OpenSim.log`, `OpenSimStats.log` | Keeps a continuous log history, handy to compare before and after the update (optional; can grow large, archive it if so) |

   Do **not** copy the `addin-db-*` folders: the new version rebuilds them.

   Do not copy `config-include/GridCommon.ini` either: take the one from the
   new Neverworld package, since the grid connection can change between
   versions (this one adds sections OpenSim-NGC Tranquillity needs to
   start). If you had changed it, for example to use MySQL, apply that change
   again to the new file.
4. **Launchers** (`opensim.bat`, `opensim.sh`): the full package already
   includes the right ones. If you extracted a plain OpenSimulator release,
   copy them from the Neverworld configuration package: `bin/opensim.bat` for
   the official OpenSimulator, or both files in `ngc/bin/` for OpenSim-NGC
   Tranquillity (see [Setup](#1-get-opensimulator-with-the-neverworld-configuration)).
   Do not bring your old ones from `opensim.old` unless you had customised
   them: the new ones may carry fixes. On Linux / macOS, if the launcher came
   from a `.zip`, make it executable: `chmod +x opensim.sh`.
5. Compare your `OpenSim.ini` with the new `OpenSim.ini.example` (and the
   `config-include/*.example` files) in case the new release added or renamed
   settings.
6. Start the simulator. Database updates are applied automatically on the first
   launch and cannot be undone — keep `opensim.old` until everything works.

## Moving a region from another grid

> **Do this while your region is still connected to the old grid.** A region
> database (`OpenSim.db`) only stores references to textures, meshes, scripts
> and object contents; the content itself lives on the old grid's asset
> server. If you only copy `OpenSim.db` and connect to Neverworld, your
> region will show grey objects and empty scripts as soon as the old grid
> shuts down or its asset server becomes unreachable.

For large moves, contact the Neverworld administrators first (see [Contact](#contact)).

1. **Save your region with its assets.** While still connected to the old grid,
   in the OpenSim console:
   ```
   change region <region name>
   save oar <region name>.oar
   ```
   Repeat for each region. Do **not** use `--no-assets`. Check the file size
   is plausible, and if you can, test it by loading it into a local standalone
   OpenSimulator.
2. **Save your inventory** (optional, if the old grid allows it). From the
   console of your own region, still connected to the old grid:
   ```
   save iar <first> <last> / <password> <first>-<last>.iar -c
   ```
    `-c` keeps the information about the original creators.
3. **Set up the region for Neverworld.** Install as described in [Setup](#setup).
   You may copy your own `config-include/FlotsamCache.ini` and `config-include/osslEnable.ini` from
   the old installation, since they hold local preferences (asset cache, OSSL
   permissions). Choose free grid coordinates on the
   [Neverworld Quick Map](https://neverworldgrid.com/neverworld-quick-map/). On first launch,
   give your Neverworld account as the estate owner.
4. **Load your region:**
   ```
   change region <region name>
   load oar <region name>.oar
   ```
   Objects whose owners do not exist on Neverworld are given to the estate owner.
5. **Load your inventory** into your Neverworld account:
   ```
   load iar <first> <last> / <password> <first>-<last>.iar
   ```
   Before loading an IAR, Neverworld's self-hosting page suggests checking it
   for problems with [customs.gridxchange.co](https://customs.gridxchange.co).

If you come from an old Mono-based OpenSimulator (0.9.2 or earlier, started
with `OpenSim.exe`), start from the `OpenSim.ini` in this package and carry
your own settings over by hand, instead of copying your old file. Mono is no
longer needed: if no other application uses it, we recommend uninstalling it,
to keep the system clean and avoid possible problems.

Respect the permissions and licences of the content you move: items made by
other creators may not be allowed on another grid.

## Contact

For help, contact the Neverworld administrators
on the **NeverWorld** server on Discord (search Discord for "NeverWorld").

## Security

**Your region, your rules.** Neverworld does not control self-hosted regions
in-world. Grid administrators get no god powers on your region
(`allow_grid_gods = false`): you set your own levels, moderation and god modes.
The only requirement is no illegal activity.

Your region is a server on the internet. A few habits keep it, and your
visitors, safe:

- **Open only the ports the simulator needs** (see [Ports](#2-configure-your-region))
  in your firewall and router. Do not expose your database, the remote console or RemoteAdmin; they
  are off in this package, keep them that way unless you know you need them.
- **Keep OpenSimulator up to date** with the official releases (see
  [Updating an existing installation](#updating-an-existing-installation)), and
  keep the operating system and the .NET runtime updated too.
- **Back up regularly** with `save oar`, and keep copies off the machine.
- **Statistics pages off**: the visitor statistics page
  (`[WebStats] enabled = false`), which would show your visitors' names and visit
  times to anyone, the region statistics (`Stats_URI = ""`; OpenSim enables it
  by default as `/jsonSimStats/`, showing how many avatars are on your region)
  and the internal statistics feed (`ManagedStatsRemoteFetchURI`, commented
  out). None has a password by default. To follow your region's statistics,
  use the console (`show stats`, `show users`) or `OpenSimStats.log`. The
  `/simstatus` address used in [Troubleshooting](#troubleshooting) only
  answers "OK" and reveals nothing.
- **Search is off** (`[Search]`): the stock value pointed to OSGrid's search
  server, which closes on 31 December 2026.

## Troubleshooting

**Checking your ports.** With the simulator running:

- **TCP (simulator port):** from a device *outside* your network (for example a
  phone on mobile data), open `http://<your public IP or FQDN>:<http_listener_port>/simstatus`.
  It should show **OK**: the port is open and OpenSimulator is answering. An
  online port checker, such as [canyouseeme.org](https://canyouseeme.org/) or
  [yougetsignal.com](https://www.yougetsignal.com/tools/open-ports/), also tests
  it, but only says whether something answers.
- **UDP (region ports):** online checkers cannot test UDP reliably. If the TCP
  check works but viewers still cannot enter or see the region, check the UDP
  forwarding of each region's `InternalPort` in your router and firewall.

**Region not visible on the grid:**
Verify that the ports are reachable from the internet (see above).

**Region on the map, but viewers cannot enter or teleport in:**
The simulator's port (TCP) is probably not reachable. Check that
`http_listener_port` in `OpenSim.ini` is the port you opened for TCP, and that
each region's `InternalPort` is open for UDP.

**Cannot connect from the same network as the server:**
Some routers do not support hairpin NAT (loopback). You cannot use your public IP
to access the region from the same LAN. Use the internal IP instead, or enable
NAT loopback in your router if it supports it.

---

## Licensing

This repository uses a dual-license structure because it contains two types of files
with different origins.

| Files | License |
|---|---|
| `README.md`, `readme.first.txt`, and any original documentation or configuration written for this repository | [GNU General Public License v2 or later](LICENSE) |
| Files derived from the OpenSimulator distribution (`OpenSim.ini`, `GridCommon.ini`, `FlotsamCache.ini`, `osslEnable.ini`, `opensim.bat`, `ngc/bin/opensim.bat`, `ngc/bin/opensim.sh`, and any other file that originates from the OpenSimulator project) | [BSD 3-Clause License](LICENSE-OpenSimulator.txt) |

**Why two licenses?**
The OpenSimulator project is distributed under the BSD 3-Clause License. That license
allows modification but requires that derivative works keep the original license notice.
We cannot relicense those files. Original contributions (documentation, custom configs
written from scratch) are released under GPL v2+ to ensure improvements remain open.

Copyright (c) 2026 eva Nowicka / ENS project
