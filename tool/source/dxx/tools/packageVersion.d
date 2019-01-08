/++
Generated at 2019-Jan-08 02:12:55.5323372
by gen-package-version unknown-ver: 
$(LINK https://github.com/Abscissa/gen-package-version)
+/
module dxx.tools.packageVersion;

/++
Version of this package.
+/
enum packageVersion = "unknown-ver";

/++
Human-readable timestamp of when this module was generated.
+/
enum packageTimestamp = "2019-Jan-08 02:12:55.5323372";

/++
Timestamp of when this module was generated, as an ISO Ext string.
Get a SysTime from this via:

------
std.datetime.fromISOExtString(packageTimestampISO)
------
+/
enum packageTimestampISO = "2019-01-08T02:12:55.5323372";
