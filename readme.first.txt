NWG.SelfHosted.Conf — Quick Setup Guide
========================================

Configuration files to connect a self-hosted OpenSimulator region
to the Neverworld grid.

For full documentation and license details, see README.md or visit:
https://github.com/Neverworld-Grid/NWG.SelfHosted.Conf

Neverworld's own self-hosting page, with the application form:
https://neverworldgrid.com/self-host-regions-on-neverworld-grid/


REQUIREMENTS
------------
- .NET 8.0 runtime for your operating system
- On Linux / macOS: libgdiplus and related libraries
- An account on the Neverworld grid and an APPROVED self-hosting
  application (see BEFORE YOU START)
- A computer that can stay on while the region runs
- A public IP address or FQDN. On a home connection your IP changes: use a
  free dynamic DNS name (e.g. No-IP, DuckDNS) and give it in your application
- Ports open in your firewall / router: the simulator's port (TCP) and one
  port per region (UDP). With a single region both can be the same (9000)

Tested with OpenSimulator 0.9.3.1 Dev (build reb01e50, 2026-10-22) and
OpenSim-NGC Tranquillity 0.9.3.9333, with both standard regions and
var-regions.

WHICH VERSION?
- OpenSim-NGC Tranquillity 0.9.3.9333: the version Neverworld runs on its
  own regions; choose it for a region that behaves exactly like the rest of
  the grid. No longer updated (July 2025), so it lacks later OpenSimulator
  fixes; it needs the launchers in ngc/bin/ to write logs (and, on
  Linux / macOS, to find its SQLite library).
- OpenSimulator 0.9.3.1 (official): actively maintained, with newer fixes
  (including security and robustness), new LSL functions and newer voice
  support. It may behave slightly differently from the grid's own regions.
The two are not interchangeable: script states are not carried between
them, and their region databases (OpenSim.db) differ. To switch, save an OAR
of each region, install the other flavour from scratch and load the OAR
there; never copy OpenSim.db across. Every script restarts from its initial
state.


BEFORE YOU START: APPLY
-----------------------
Self-hosted regions must be registered before they can connect. Fill in
the Self-Hosting Application Form (log in to your Neverworld account on the
website first):
  https://neverworldgrid.com/self-hosting-application-form/
You can prepare everything meanwhile, but start the region only after you
receive the approval email.


SETUP
-----

1. Get OpenSimulator with the Neverworld configuration. Two ways:

   a) Full package (recommended): OpenSimulator with the Neverworld
      configuration already in place, from the Releases page of
      https://github.com/Neverworld-Grid/NWG.SelfHosted.Conf
      Extract it to a folder of your choice; nothing else to copy.

   b) Configuration only: download the latest OpenSimulator release from
      the official GitHub repository, extract it (the Tranquillity archive
      has no bin/ folder: extract it into a bin/ folder you create), and
      copy the files from the bin/ folder of this package into the bin/
      folder of your installation, replacing any existing files:
        - OpenSim.ini
        - opensim.bat (Windows launcher)
        - config-include/FlotsamCache.ini
        - config-include/GridCommon.ini
        - config-include/osslEnable.ini

      OpenSim-NGC Tranquillity only: then also copy ngc/bin/opensim.bat
      and ngc/bin/opensim.sh into the same bin/ folder. Tranquillity writes
      no logs unless started with -logconfig=OpenSim.dll.config, which
      these launchers do. On Linux / macOS: chmod +x opensim.sh

      On Linux / macOS, opensim.sh also copies Tranquillity's SQLite
      library from bin/runtimes/ into bin/ on the first start; without it
      the region stops with "Unable to load shared library
      'SQLite.Interop.dll'".

2. Configure your region.
   Create Regions/Region.ini (or let OpenSim generate it on first launch).
   Copy Regions/Regions.ini.example (included in the distribution, with
   every setting explained) to Regions/Region.ini and review it. Standard
   regions and var-regions both work; for a var-region set SizeX and SizeY
   (multiples of 256). You will need:
     - A unique region name
     - A new UUID for your region (generate one at uuidgenerator.net)
     - Grid coordinates: choose a free spot on the Neverworld Quick Map
       (https://neverworldgrid.com/neverworld-quick-map/)
     - ExternalHostName: the public address or hostname you gave in your
       application. When the console asks for it on first launch, type it
       in; do not accept the suggested value
     - The region's port, InternalPort (UDP), different for each region

   Ports: the simulator uses http_listener_port ([Network] section of
   OpenSim.ini) over TCP; each region uses its own InternalPort over UDP.
     - One region: simplest is the same number for both (9000 in this
       package), open for TCP and UDP.
     - Several regions: one InternalPort per region (e.g. 9001, 9002...)
       open for UDP, plus http_listener_port open for TCP. Only one region
       can share its number with the simulator port.

   Hostname: in the [Network] section of OpenSim.ini, replace
   YOUR.PUBLIC.HOSTNAME in ExternalHostNameForLSL with your public IP or
   FQDN (same as ExternalHostName). Scripts using HTTP-in (llRequestURL)
   need it; until you set it, HTTP-in stays disabled.

3. Launch:
     Windows:       .\opensim.bat
     Linux / macOS: ./opensim.sh

   On first launch OpenSim will prompt for region details if Region.ini
   does not exist yet.

   Start the region once your application has been approved; it then
   appears on Neverworld.

   Keeping your approval: it lasts while the region is in use. A region
   server offline for 60 days is removed from the list; to come back, ask
   the Neverworld administrators to reactivate it (see CONTACT).

   To rename a region or add one, edit Regions/*.ini and restart; let the
   Neverworld administrators know, so their records stay up to date.

GRID SETTINGS AND YOUR OWN SETTINGS
-----------------------------------
The values in this package are the ones known to work with Neverworld.

- Grid connection, leave as it is (unless the Neverworld administrators
  say otherwise). It is defined once, in the [Const] section of
  OpenSim.ini: BaseHostname and its ports (PublicPort 8002, PrivatePort
  8003). Every grid address elsewhere (GridCommon.ini, [Groups],
  [UserProfiles]...) is built from those variables as ${Const|...}; keep
  it that way. The [Architecture] include also stays as it is.
- Yours to fill in: Regions/*.ini, the ports and ExternalHostNameForLSL.
- Yours to adapt to what you want to do on your region: OSSL permissions
  (config-include/osslEnable.ini), the asset cache (FlotsamCache.ini),
  physics, scripting, permissions and the rest of OpenSim.ini. Read the
  comments next to each setting and the OpenSimulator wiki first:
    http://opensimulator.org/wiki/Configuration
    http://opensimulator.org/wiki/OSSL_Enabling_Functions
  Keep the SECURITY defaults unless you know why you are changing them.

UPDATE AN EXISTING INSTALLATION
--------------------------------

1. Back up first. In the OpenSim console run 'save oar <file>.oar' for each
   region, then stop the simulator with 'shutdown' (do not just close the window).
2. Rename the current folder, e.g. 'opensim' → 'opensim.old', and extract the
   new release into a fresh 'opensim' folder.
3. Copy these from 'opensim.old/bin/' into 'opensim/bin/':

    - 'OpenSim.ini' (Your simulator settings)
    - 'config-include/FlotsamCache.ini', 'osslEnable.ini' (Cache and OSSL settings)
    - 'Regions/*.ini' (Your region definitions)
    - 'OpenSim.db' (Region contents: objects, terrain, estate (SQLite);
      with OpenSim-NGC Tranquillity the file is named
      'OpenSim.db,version=3,UseUTF16Encoding=True')
    - 'ScriptEngines/' (Script states (optional; without it scripts restart fresh))
    - 'assetcache/' (Asset cache (optional; avoids downloading everything again))
    - 'OpenSimConsoleHistory.txt' (Console command history (optional))
    - 'OpenSim.log', 'OpenSimStats.log' (Keeps a continuous log history, handy to compare before and after the update (optional; can grow large, archive it if so))

   Do not copy the 'addin-db-*' folders: the new version rebuilds them.

   Do not copy 'config-include/GridCommon.ini' either: take the one from
   the new Neverworld package, since the grid connection can change
   between versions (this one adds sections OpenSim-NGC Tranquillity needs
   to start). If you had changed it, for example to use MySQL, apply that
   change again to the new file.
4. Launchers ('opensim.bat', 'opensim.sh'): the full package already
   includes the right ones. If you extracted a plain OpenSimulator release,
   copy them from the Neverworld configuration package: 'bin/opensim.bat'
   for the official OpenSimulator, or both files in 'ngc/bin/' for
   OpenSim-NGC Tranquillity. Do not bring your old ones from 'opensim.old'
   unless you had customised them: the new ones may carry fixes. On
   Linux / macOS, if the launcher came from a .zip, make it executable:
   'chmod +x opensim.sh'.
5. Compare your 'OpenSim.ini' with the new 'OpenSim.ini.example' (and the
   'config-include/*.example' files) in case the new release added or renamed
   settings.
6. Start the simulator. Database updates are applied automatically on the first
   launch and cannot be undone — keep 'opensim.old' until everything works.

MOVING A REGION FROM ANOTHER GRID
---------------------------------

IMPORTANT: do this while your region is still connected to the old grid.
OpenSim.db only stores references to textures, meshes, scripts and object
contents; the content itself lives on the old grid's asset server. Copying
only OpenSim.db gives grey objects and empty scripts once the old grid
shuts down or its asset server becomes unreachable.

For large moves, contact the Neverworld administrators first (see CONTACT).

1. Save each region with its assets (still on the old grid):
     change region <region name>
     save oar <region name>.oar
   Do not use --no-assets. Check the file size; if you can, test-load it
   into a local standalone OpenSimulator.

2. Save your inventory (optional, if the old grid allows it):
     save iar <first> <last> / <password> <first>-<last>.iar -c
   
   (-c keeps the information about the original creators) 

3. Set up the region for Neverworld as in SETUP. You may copy your own
   config-include/FlotsamCache.ini and config-include/osslEnable.ini from
   the old installation (local preferences: asset cache, OSSL
   permissions). Choose free grid coordinates on the Neverworld Quick
   Map (https://neverworldgrid.com/neverworld-quick-map/). On first
   launch, give your Neverworld account as the estate owner.

4. Load your region:
     change region <region name>
     load oar <region name>.oar
   Objects whose owners do not exist on Neverworld go to the estate owner.

5. Load your inventory into your Neverworld account:
     load iar <first> <last> / <password> <first>-<last>.iar
   Before loading an IAR, Neverworld's self-hosting page suggests checking
   it for problems with https://customs.gridxchange.co

Coming from an old Mono-based OpenSimulator (0.9.2 or earlier, started
with OpenSim.exe)? Start from the OpenSim.ini in this package and carry
your own settings over by hand. Mono is no longer needed: if no other
application uses it, we recommend uninstalling it, to keep the system
clean and avoid possible problems.

Respect the permissions and licences of the content you move: items made
by other creators may not be allowed on another grid.

CONTACT
-------
For help, contact the Neverworld administrators on the
NeverWorld server on Discord (search Discord for "NeverWorld").

SECURITY
--------
Your region, your rules: Neverworld does not control self-hosted regions
in-world. Grid administrators get no god powers on your region
(allow_grid_gods = false); you set your own levels, moderation and god
modes. The only requirement is no illegal activity.

- Open only the ports the simulator needs (see Ports above). Do not expose your
  database, the remote console or RemoteAdmin (off in this package).
- Keep OpenSimulator, the operating system and .NET up to date.
- Back up regularly with 'save oar' and keep copies off the machine.
- The visitor statistics page ([WebStats]), the region statistics
  (Stats_URI, on by default as /jsonSimStats/), the internal statistics
  feed (ManagedStatsRemoteFetchURI) and search ([Search], which pointed to
  OSGrid's closing server) are off. Follow your region's statistics in the
  console (show stats, show users) or in OpenSimStats.log. The /simstatus
  address only answers "OK" and reveals nothing.

TROUBLESHOOTING
---------------

Checking your ports (simulator running):
  - TCP: from a device outside your network (e.g. a phone on mobile data)
    open http://<your public IP or FQDN>:<http_listener_port>/simstatus
    It should show OK. Online checkers (canyouseeme.org,
    yougetsignal.com/tools/open-ports) also test TCP.
  - UDP: online checkers cannot test it reliably. If TCP works but viewers
    cannot enter, check the UDP forwarding of each region's InternalPort.

Region not visible on the grid:
  Check that the ports are reachable from the internet (see above).

Region on the map, but viewers cannot enter or teleport in:
  The simulator's port (TCP) is probably not reachable. Check that
  http_listener_port in OpenSim.ini is the port you opened for TCP, and
  that each region's InternalPort is open for UDP.

Cannot connect from the same network as the server:
  Some routers do not support hairpin NAT (loopback). Use the internal IP
  to connect from the same LAN, or enable NAT loopback in your router.


LICENSE
-------
Original files in this package (documentation, custom configuration):
  GNU General Public License v2 or later — see LICENSE

Files derived from the OpenSimulator project (OpenSim.ini, GridCommon.ini,
FlotsamCache.ini, osslEnable.ini, opensim.bat, ngc/bin/opensim.bat,
ngc/bin/opensim.sh, and any other file originating from OpenSimulator):
  BSD 3-Clause License — see LICENSE-OpenSimulator.txt

Copyright (c) 2026 eva Nowicka / ENS project
