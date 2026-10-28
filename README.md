# NWG.SelfHosted.Conf

Configuration files to connect a self-hosted OpenSimulator region to the **Neverworld grid**.

## What is this

If you want to run your own OpenSimulator region and have it appear on the Neverworld grid,
you need a few configuration files that differ from a standalone setup. This repository
provides those files along with a step-by-step setup guide.

Neverworld's own page on self-hosting, with the application form, is
[Self-host regions on Neverworld Grid](https://neverworldgrid.com/self-host-regions-on-neverworld-grid/).

## Requirements

- [.NET 8.0 runtime](https://dotnet.microsoft.com/download/dotnet/8.0) for
  your operating system. It must be version 8: having only a newer one
  (such as .NET 10) is not enough
- On Linux / macOS: `libgdiplus` and related libraries
- An account on the Neverworld grid and an **approved self-hosting application**
  (see [Before you start](#before-you-start-apply))
- A computer that can stay on while the region runs. As a rough guide, each
  region wants a CPU core and around a gigabyte of memory to itself; more if
  your viewer runs on the same computer. A wired connection works better than Wi-Fi
- A public IPv4 address. If your provider uses carrier-grade NAT (CGNAT), port
  forwarding cannot work: ask your provider for a public one. On a home
  connection the address changes, so use a free dynamic DNS name (for example
  No-IP or DuckDNS) and give that name in your application
- A fixed local IP address for the computer (a DHCP reservation in your
  router), so the port forwarding keeps pointing at it
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
then restarts from its initial state. Keep the same `RegionUUID` in the new
installation (landmarks to your region keep working), and never run both
installations at the same time.

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
  [Releases](../../releases). Extract it to a folder of your choice, with a
  short path (e.g. `C:\OpenSim` or `~/opensim`): you will type it in console
  commands. Nothing else to copy: go on to step 2.
- **Configuration only** (this repository): if you already have OpenSimulator,
  or prefer to download the official release yourself from the OpenSimulator
  GitHub repository, extract it and copy the files from this repository's
  `bin/` folder into the `bin/` folder of your installation, replacing any
  existing files with the same name:
  - `OpenSim.ini`
  - `opensim.bat` and `opensim.sh` (launchers for Windows and for
    Linux / macOS)
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
# Both:
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
| Region UUID | A new UUID — generate one at [uuidgenerator.net](https://www.uuidgenerator.net). **Keep it**: the region's content is tied to it, and with a new UUID the region starts empty |
| Grid coordinates (`Location`) | A free spot you choose on the [Neverworld Quick Map](https://neverworldgrid.com/neverworld-quick-map/), written `x,y`. A var-region covers several map squares, and all of them must be free. Unless you want neighbours, leave some space around other people's regions |
| InternalAddress | `0.0.0.0` |
| InternalPort | The region's UDP port (e.g. `9000`), different for each region |
| AllowAlternatePorts | `False` (the default): the region always uses the port you set |
| ExternalHostName | The public address or hostname you gave in your application. When the console asks for it on first launch, type it in; do not accept the suggested value |

**Estate:** on first launch the console also asks for an estate name and its
owner. The estate name is hard to change later, so choose it with care. For the
owner, type your Neverworld account's first and last name exactly.

**Ports.** The simulator listens on `http_listener_port` (in the `[Network]`
section of `OpenSim.ini`) over **TCP**; each region listens on its own
`InternalPort` over **UDP**. With one region, the simplest is to use the same
number for both (the package uses `9000`) and open that port for TCP and UDP.

**Your hostname in `OpenSim.ini`.** In the `[Network]` section, replace
`YOUR.PUBLIC.HOSTNAME` in `ExternalHostNameForLSL` with your public IP or FQDN
(the same value as `ExternalHostName`). Scripts that use HTTP-in
(`llRequestURL`) build their URLs from it; until you set it, HTTP-in stays
disabled.

### 3. Launch

Start it from a console, not with a double-click: if the region stops, the
console stays open and you can read why.

- **Windows:** in File Explorer, open the `bin/` folder, type `cmd` in the
  address bar and press Enter; then run `.\opensim.bat`
- **Linux / macOS:** open a terminal in the `bin/` folder and run `./opensim.sh`

The launcher first checks that the .NET 8 runtime is installed. If it is not,
it says so, shows the runtimes it found, and stops. On Windows, if the region
stops with an error, the window waits for a key before closing.

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
   copy them from the Neverworld configuration package: both files in `bin/`
   for the official OpenSimulator, or both files in `ngc/bin/` for OpenSim-NGC
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
   - `load oar` replaces everything in the destination region. Back it up
     first, and check that the console is on the right region (`change region`).
   - On a var-region, check afterwards that the parcels cover the whole region.
   - Owners *and groups* may not exist on Neverworld: check the group
     assignments of your objects too.
5. **Load your inventory** into your Neverworld account. Load it into a folder
   of its own rather than into your inventory root: create the folder in your
   viewer first, then:
   ```
   load iar --merge <first> <last> "<folder>" <password> <first>-<last>.iar
   ```
   Before loading an IAR, Neverworld's self-hosting page suggests checking it
   for problems with [customs.gridxchange.co](https://customs.gridxchange.co).

   **Inventory (IAR) tips:**
   - Saved outfits: before exporting, copy the contents of your *Outfits*
     system folder into a normal folder; after importing, copy them back into
     *Outfits*. Never delete system folders.
   - If the console says "Password incorrect" although your password works in
     the viewer, set a temporary password with only letters and digits for the
     transfer, and change it afterwards.
   - Large inventories can take hours to export and to import. Do not start
     another import meanwhile; if folders look empty, wait and relog.

If you come from an old Mono-based OpenSimulator (0.9.2 or earlier, started
with `OpenSim.exe`), start from the `OpenSim.ini` in this package and carry
your own settings over by hand, instead of copying your old file. Mono is no
longer needed: if no other application uses it, we recommend uninstalling it,
to keep the system clean and avoid possible problems.

Respect the permissions and licences of the content you move: items made by
other creators may not be allowed on another grid.

## Contact

For help, contact the Neverworld administrators
on the **NeverWorld** server on Discord (search Discord for "NeverWorld"),
in the **#regions** channel.
Include the details listed in [Asking for help](#still-stuck-asking-for-help),
so they can help you quickly.

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
- **Back up regularly:** `save oar` for each region, and copies of the region
  database (`OpenSim.db`), `Regions/*.ini`, `OpenSim.ini` and
  `config-include/*.ini`, kept on another drive.
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

**The launcher closes at once, with no message and no log:**
.NET 8 is probably missing. Use the launchers from this package, which check
it and tell you, or run `dotnet --list-runtimes`: you need a line starting
with `Microsoft.NETCore.App 8.`. If there is none, install the
[.NET 8.0 runtime](https://dotnet.microsoft.com/download/dotnet/8.0).
If .NET is installed and the window still closes, start the launcher from a
console (see [Launch](#3-launch)) to read the error.

**The region stops during start-up:** read the last lines of `OpenSim.log`
(in `bin/`). Common messages:

| Message (part of it) | Meaning |
|---|---|
| `Region overlaps another region` | The coordinates are taken. Choose another free spot; it can also be your own region, still registered after it was closed without `shutdown` (ask the administrators) |
| `Halting startup due to conflicts in region configurations` | Two regions in your `Regions/*.ini` share a name, UUID, location or `InternalPort` |
| `Address already in use` / `Only one usage of each socket address` | Another program, or another simulator, already uses that port |
| `Could not resolve external hostname` | Your hostname does not point to your IP: check your dynamic DNS name |
| `OutOfMemoryException` | Not enough memory for the simulator |

**Always stop the simulator with `shutdown`** in its console, not
by closing the window: closing it can leave the region registered on the grid
and can damage its database.

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

**Does the grid know about my region?** [ORBIT](https://neverworldgrid.com/orbit-region-management-dashboard/),
Neverworld's region dashboard (you need to register to log in), lists the
self-hosted regions too, so you can check that yours is there. For
self-hosted regions it only shows them: you cannot save an OAR or restart
them from ORBIT.

**Region not visible on the grid:**
Verify that the ports are reachable from the internet (see above).

**Ports forwarded, but the test fails:** check the router itself.
- You need **port forwarding**, not "port triggering" or "port filtering".
- Forward the ports to the **computer's** local IP address (e.g.
  `192.168.1.50`), not to the router's own address (the "gateway", often
  `192.168.1.1`).
- Many routers only apply a rule after you tick *enable* and save it; some
  also need a restart.
- Some routers have their own firewall as well (options such as "block
  anonymous internet requests"), which must allow the same ports.
- If a single rule for "TCP and UDP" does not work, create two rules, one per
  protocol.
- **Double NAT:** if the "external" or "WAN" IP shown by your router starts with
  `192.168.`, `10.` or `172.16.`–`172.31.`, there is another router in front of
  it (often the provider's) where the ports must be forwarded too. If it starts
  with `100.64.`–`100.127.`, your provider uses CGNAT (see
  [Requirements](#requirements)).
- Some providers block common ports such as `8080` or `9000`. Try other ports
  (never below 1024; `49152`–`65535` are usually free), and change them in the
  router, `OpenSim.ini` and `Regions/*.ini` alike.

**Ports open in the router, but the test fails or nobody can enter:**
The computer's own firewall may be blocking them.
- **Windows:** the first time the simulator starts, Windows asks whether to
  allow `dotnet` to accept connections. If you missed or refused that
  question, open *Windows Security → Firewall & network protection → Allow an
  app through firewall* and allow `dotnet`, or add inbound rules for your
  ports (TCP `http_listener_port`, UDP each `InternalPort`).
- **Linux:** if a firewall is active (`ufw`, `firewalld`), open the same ports
  there.

**Region on the map, but viewers cannot enter or teleport in:**
The simulator's port (TCP) is probably not reachable; if the console shows
nothing at all when someone tries to enter, the connection is not reaching
your computer. Check that `http_listener_port` in `OpenSim.ini` is the port you
opened for TCP, and that each region's `InternalPort` is open for UDP. Changing
the ports only in `OpenSim.ini` makes it worse: the router must forward the
same ones.

**Viewer stuck at "Waiting for region handshake":**
The region's UDP port is not reachable, or `ExternalHostName` is wrong. Check
the UDP forwarding of the region's `InternalPort` and the hostname.

**Region unreachable after your IP changed:**
Check that your dynamic DNS name is updating, and that it matches
`ExternalHostName` and `ExternalHostNameForLSL`. If your router can update the
dynamic DNS name itself, set it up there: it is more reliable than a program
on the computer. After a power cut or a router restart, also check that the
computer kept its local IP address (see the DHCP reservation in
[Requirements](#requirements)).

**Cannot connect from the same network as the server:**
Some routers do not support hairpin NAT (loopback). You cannot use your public IP
to access the region from the same LAN. Use the internal IP instead, or enable
NAT loopback in your router if it supports it. If the provider's router lacks
it, check whether it has a "bridge mode": in that mode it only passes the
connection through, and a router of your own that supports loopback does the
rest. Some routers also refuse to
resolve your own dynamic DNS name from inside your network ("DNS rebind
protection"); add the name as an exception in the router. On Wi-Fi, some
routers put wireless devices on a separate network that port forwarding does
not reach; a cable avoids the problem.

### Still stuck? Asking for help

"It doesn't work" is not enough for anyone to help you. When you ask the
Neverworld administrators (see [Contact](#contact)), describe exactly what you
see and include:

- Your **region name**
- The **package and version** you use (the file name you downloaded, e.g.
  `NWG-SelfHosted-OpenSimulator-reb01e50-20261025.zip`) and your **operating
  system**
- **What you did and what happens**: the exact error message, and at what
  point it stops (the launcher closes, the console stops at a question, the
  region is not on the map, you cannot teleport in…)
- **Did it ever work?** If it did, what changed since then (an update, a
  router or power restart, a new IP address, a moved cable…)
- The result of the **`/simstatus` test** (see [Checking your ports](#troubleshooting))
- **Screenshots**, and the last lines of `OpenSim.log` (in `bin/`) if it exists
- If asked, your `Regions/*.ini` and `OpenSim.ini`

Before sharing files or screenshots, remove passwords, and your IP address
if you prefer not to make it public.

## References and thanks

- **MaryStGeorge**, ["OSgrid → Neverworld — A Short Self-Hosting Migration Guide"](https://discord.com/channels/541036640076955658/565358245225562113/1562220189448151160),
  published on the NeverWorld Discord server (the link opens for server
  members; see [Contact](#contact) to join). Several of the tips in
  [Moving a region from another grid](#moving-a-region-from-another-grid) and
  [Troubleshooting](#troubleshooting) come from her notes.
- **Gundahar Bravin**, for the OpenSim-NGC Tranquillity launcher that starts
  it with `-logconfig=OpenSim.dll.config`, on which the launchers in
  `ngc/bin/` are based.

---

## Licensing

This repository uses a dual-license structure because it contains two types of files
with different origins.

| Files | License |
|---|---|
| `README.md`, `readme.first.txt`, and any original documentation or configuration written for this repository | [GNU General Public License v2 or later](LICENSE) |
| Files derived from the OpenSimulator distribution (`OpenSim.ini`, `GridCommon.ini`, `FlotsamCache.ini`, `osslEnable.ini`, `opensim.bat`, `opensim.sh`, `ngc/bin/opensim.bat`, `ngc/bin/opensim.sh`, and any other file that originates from the OpenSimulator project) | [BSD 3-Clause License](LICENSE-OpenSimulator.txt) |

**Why two licenses?**
The OpenSimulator project is distributed under the BSD 3-Clause License. That license
allows modification but requires that derivative works keep the original license notice.
We cannot relicense those files. Original contributions (documentation, custom configs
written from scratch) are released under GPL v2+ to ensure improvements remain open.

Copyright (c) 2026 eva Nowicka / ENS project
