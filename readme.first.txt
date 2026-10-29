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
  (https://dotnet.microsoft.com/download/dotnet/8.0). It must be
  version 8: having only a newer one (such as .NET 10) is not enough
- On Linux / macOS: libgdiplus and related libraries
- An account on the Neverworld grid and an APPROVED self-hosting
  application (see BEFORE YOU START)
- A computer that can stay on while the region runs. As a rough guide,
  each region wants a CPU core and around a gigabyte of memory to itself;
  more if your viewer runs on the same computer. A wired connection works
  better than Wi-Fi
- A public IPv4 address. If your provider uses carrier-grade NAT (CGNAT),
  port forwarding cannot work: ask your provider for a public one. On a
  home connection the address changes: use a free dynamic DNS name (e.g.
  No-IP, DuckDNS) and give that name in your application
- A fixed local IP address for the computer (a DHCP reservation in your
  router), so the port forwarding keeps pointing at it
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
state. Keep the same RegionUUID in the new installation (landmarks to your
region keep working), and never run both installations at the same time.


BEFORE YOU START: APPLY
-----------------------
Self-hosted regions must be registered before they can connect. Fill in
the Self-Hosting Application Form (log in to your Neverworld account on the
website first):
  https://neverworldgrid.com/self-hosting-application-form/
You can prepare everything meanwhile, but start the region only after you
receive the approval email.

In the application, give a hostname (a DNS name), the same one you will
use as ExternalHostName. If your IP is dynamic, as on most home
connections, it must be a dynamic DNS (DDNS) name that updates itself. If
your IP is static, a normal DNS name or the IP itself works too. The grid
only lets your region in from the address that name points to.


SETUP
-----

1. Get OpenSimulator with the Neverworld configuration. Two ways:

   a) Full package (recommended): OpenSimulator with the Neverworld
      configuration already in place, from the Releases page of
      https://github.com/Neverworld-Grid/NWG.SelfHosted.Conf
      Extract it to a folder with a short path (e.g. C:\OpenSim or
      ~/opensim), as you will type it in console commands; nothing else
      to copy.

   b) Configuration only: download the latest OpenSimulator release from
      the official GitHub repository, extract it (the Tranquillity archive
      has no bin/ folder: extract it into a bin/ folder you create), and
      copy the files from the bin/ folder of this package into the bin/
      folder of your installation, replacing any existing files:
        - OpenSim.ini
        - opensim.bat and opensim.sh (launchers for Windows and for
          Linux / macOS)
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
     - A new UUID for your region (generate one at uuidgenerator.net).
       Keep it: the region's content is tied to it, and with a new UUID
       the region starts empty
     - Grid coordinates (Location, written x,y): choose a free spot on the
       Neverworld Quick Map (https://neverworldgrid.com/neverworld-quick-map/).
       A var-region covers several map squares, and all must be free.
       Unless you want neighbours, leave some space around other regions
     - ExternalHostName: the public address or hostname you gave in your
       application. When the console asks for it on first launch, type it
       in; do not accept the suggested value
     - The region's port, InternalPort (UDP), different for each region
     - AllowAlternatePorts = False (the default)

   Estate: on first launch the console also asks for an estate name and
   its owner. The estate name is hard to change later; for the owner, type
   your Neverworld account's first and last name exactly.

   Ports: the simulator uses http_listener_port ([Network] section of
   OpenSim.ini) over TCP; each region uses its own InternalPort over UDP.
   With one region, the simplest is the same number for both (9000 in this
   package), open for TCP and UDP.

   Hostname: in the [Network] section of OpenSim.ini, replace
   YOUR.PUBLIC.HOSTNAME in ExternalHostNameForLSL with your public IP or
   FQDN (same as ExternalHostName). Scripts using HTTP-in (llRequestURL)
   need it; until you set it, HTTP-in stays disabled.

3. Launch:
   Start it from a console, not with a double-click: if the region stops,
   the console stays open and you can read why.
     Windows:       in File Explorer, open the bin/ folder, type cmd in
                    the address bar and press Enter; then run .\opensim.bat
     Linux / macOS: open a terminal in the bin/ folder and run ./opensim.sh

   The launcher first checks that the .NET 8 runtime is installed. If it
   is not, it says so, shows the runtimes it found, and stops. On
   Windows, if the region stops with an error, the window waits for a key
   before closing.

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
   copy them from the Neverworld configuration package: both files in
   'bin/' for the official OpenSimulator, or both files in 'ngc/bin/' for
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
   - 'load oar' replaces everything in the destination region. Back it up
     first, and check that the console is on the right region.
   - On a var-region, check afterwards that the parcels cover the whole
     region.
   - Owners and groups may not exist on Neverworld: check the group
     assignments of your objects too.

5. Load your inventory into your Neverworld account, into a folder of its
   own rather than your inventory root (create the folder in your viewer
   first):
     load iar --merge <first> <last> "<folder>" <password> <first>-<last>.iar
   Before loading an IAR, Neverworld's self-hosting page suggests checking
   it for problems with https://customs.gridxchange.co

   Inventory (IAR) tips:
   - Saved outfits: before exporting, copy the contents of your Outfits
     system folder into a normal folder; after importing, copy them back
     into Outfits. Never delete system folders.
   - If the console says "Password incorrect" although your password works
     in the viewer, set a temporary password with only letters and digits
     for the transfer, and change it afterwards.
   - Large inventories can take hours to export and to import. Do not start
     another import meanwhile; if folders look empty, wait and relog.

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
NeverWorld server on Discord (search Discord for "NeverWorld"), in the
#regions channel.
Include the details listed in TROUBLESHOOTING, "Still stuck? Asking for
help", so they can help you quickly.

SECURITY
--------
Your region, your rules: Neverworld does not control self-hosted regions
in-world. Grid administrators get no god powers on your region
(allow_grid_gods = false); you set your own levels, moderation and god
modes. The only requirement is no illegal activity.

- Open only the ports the simulator needs (see Ports above). Do not expose your
  database, the remote console or RemoteAdmin (off in this package).
- Keep OpenSimulator, the operating system and .NET up to date.
- Back up regularly: 'save oar' for each region, and copies of the region
  database (OpenSim.db), Regions/*.ini, OpenSim.ini and
  config-include/*.ini, kept on another drive.
- The visitor statistics page ([WebStats]), the region statistics
  (Stats_URI, on by default as /jsonSimStats/), the internal statistics
  feed (ManagedStatsRemoteFetchURI) and search ([Search], which pointed to
  OSGrid's closing server) are off. Follow your region's statistics in the
  console (show stats, show users) or in OpenSimStats.log. The /simstatus
  address only answers "OK" and reveals nothing.

TROUBLESHOOTING
---------------

The launcher closes at once, with no message and no log:
  .NET 8 is probably missing. Use the launchers from this package, which
  check it and tell you, or run 'dotnet --list-runtimes': you need a line
  starting with "Microsoft.NETCore.App 8.". If there is none, install the
  .NET 8.0 runtime (https://dotnet.microsoft.com/download/dotnet/8.0).
  If .NET is installed and the window still closes, start the launcher
  from a console (see Launch) to read the error.

The region stops during start-up:
  Read the last lines of OpenSim.log (in bin/). Common messages:
  - "Region overlaps another region": the coordinates are taken. Choose
    another free spot; it can also be your own region, still registered
    after it was closed without 'shutdown' (ask the administrators).
  - "Halting startup due to conflicts in region configurations": two
    regions in your Regions/*.ini share a name, UUID, location or
    InternalPort.
  - "Address already in use" / "Only one usage of each socket address":
    another program, or another simulator, already uses that port.
  - "Could not resolve external hostname": your hostname does not point to
    your IP; check your dynamic DNS name.
  - "OutOfMemoryException": not enough memory for the simulator.

Always stop the simulator with 'shutdown' in its console, not
by closing the window: closing it can leave the region registered on the
grid and can damage its database.

Checking your ports (simulator running):
  - TCP: from a device outside your network (e.g. a phone on mobile data)
    open http://<your public IP or FQDN>:<http_listener_port>/simstatus
    It should show OK. Online checkers (canyouseeme.org,
    yougetsignal.com/tools/open-ports) also test TCP.
  - UDP: online checkers cannot test it reliably. If TCP works but viewers
    cannot enter, check the UDP forwarding of each region's InternalPort.

Does the grid know about my region?
  ORBIT, Neverworld's region dashboard (you need to register to log in),
  lists the self-hosted regions too, so you can check that yours is there.
  For self-hosted regions it only shows them: you cannot save an OAR or
  restart them from ORBIT.
  https://neverworldgrid.com/orbit-region-management-dashboard/

Region not visible on the grid:
  Check that the ports are reachable from the internet (see above).

Ports forwarded, but the test fails: check the router itself.
  - You need port forwarding, not "port triggering" or "port filtering".
  - Forward the ports to the computer's local IP address (e.g.
    192.168.1.50), not to the router's own address (the "gateway", often
    192.168.1.1).
  - Many routers only apply a rule after you tick "enable" and save it;
    some also need a restart.
  - Some routers have their own firewall as well (options such as "block
    anonymous internet requests"), which must allow the same ports.
  - If a single rule for "TCP and UDP" does not work, create two rules,
    one per protocol.
  - Double NAT: if the "external" or "WAN" IP shown by your router starts
    with 192.168., 10. or 172.16.-172.31., there is another router in
    front of it (often the provider's) where the ports must be forwarded
    too. If it starts with 100.64.-100.127., your provider uses CGNAT
    (see REQUIREMENTS).
  - Some providers block common ports such as 8080 or 9000. Try other
    ports (never below 1024; 49152-65535 are usually free), and change
    them in the router, OpenSim.ini and Regions/*.ini alike.

Ports open in the router, but the test fails or nobody can enter:
  The computer's own firewall may be blocking them.
  - Windows: the first time the simulator starts, Windows asks whether to
    allow 'dotnet' to accept connections. If you missed or refused that
    question, open Windows Security > Firewall & network protection >
    Allow an app through firewall and allow 'dotnet', or add inbound
    rules for your ports (TCP http_listener_port, UDP each InternalPort).
  - Linux: if a firewall is active (ufw, firewalld), open the same ports
    there.

Region on the map, but viewers cannot enter or teleport in:
  The simulator's port (TCP) is probably not reachable; if the console
  shows nothing at all when someone tries to enter, the connection is not
  reaching your computer. Check that http_listener_port in OpenSim.ini is
  the port you opened for TCP, and that each region's InternalPort is open
  for UDP. Changing the ports only in OpenSim.ini makes it worse: the
  router must forward the same ones.

Viewer stuck at "Waiting for region handshake":
  The region's UDP port is not reachable, or ExternalHostName is wrong.
  Check the UDP forwarding of the region's InternalPort and the hostname.

Region unreachable after your IP changed:
  Check that your dynamic DNS name is updating, and that it matches
  ExternalHostName and ExternalHostNameForLSL. If your router can update
  the dynamic DNS name itself, set it up there: it is more reliable than a
  program on the computer. Make sure it updates the IPv4 address (A
  record), not only the IPv6 one: 'nslookup -type=A <your hostname>' must
  show the same IP as a site such as whatismyip.com. After a power cut or a router restart, also
  check that the computer kept its local IP address (see the DHCP
  reservation in REQUIREMENTS).

Cannot connect from the same network as the server:
  Some routers do not support hairpin NAT (loopback). Use the internal IP
  to connect from the same LAN, or enable NAT loopback in your router. If
  the provider's router lacks it, check whether it has a "bridge mode": in
  that mode it only passes the connection through, and a router of your
  own that supports loopback does the rest.
  Some routers also refuse to resolve your own dynamic DNS name from
  inside your network ("DNS rebind protection"); add the name as an
  exception in the router. On Wi-Fi, some routers put wireless devices on
  a separate network that port forwarding does not reach; a cable avoids
  the problem.

Still stuck? Asking for help:
  "It doesn't work" is not enough for anyone to help you. When you ask
  the Neverworld administrators (see CONTACT), describe exactly what you
  see and include:
  - your region name
  - the package and version you use (the file name you downloaded) and
    your operating system
  - what you did and what happens: the exact error message, and at what
    point it stops (the launcher closes, the console stops at a question,
    the region is not on the map, you cannot teleport in...)
  - did it ever work? If it did, what changed since then (an update, a
    router or power restart, a new IP address, a moved cable...)
  - the result of the /simstatus test (see Checking your ports)
  - screenshots, and the last lines of OpenSim.log (in bin/) if it exists
  - if asked, your Regions/*.ini and OpenSim.ini
  Before sharing files or screenshots, remove passwords, and your IP
  address if you prefer not to make it public.

REFERENCES AND THANKS
---------------------
- MaryStGeorge, "OSgrid -> Neverworld - A Short Self-Hosting Migration Guide",
  published on the NeverWorld Discord server (opens for server members;
  see CONTACT to join). Several of the tips in MOVING A REGION FROM
  ANOTHER GRID and TROUBLESHOOTING come from her notes.
  https://discord.com/channels/541036640076955658/565358245225562113/1562220189448151160
- Gundahar Bravin, for the OpenSim-NGC Tranquillity launcher that starts
  it with -logconfig=OpenSim.dll.config, on which the launchers in
  ngc/bin/ are based.


LICENSE
-------
Original files in this package (documentation, custom configuration):
  GNU General Public License v2 or later — see LICENSE

Files derived from the OpenSimulator project (OpenSim.ini, GridCommon.ini,
FlotsamCache.ini, osslEnable.ini, opensim.bat, opensim.sh,
ngc/bin/opensim.bat,
ngc/bin/opensim.sh, and any other file originating from OpenSimulator):
  BSD 3-Clause License — see LICENSE-OpenSimulator.txt

Copyright (c) 2026 eva Nowicka / ENS project
