# AFWall+ Tweak

Your Android OS needs (_iptables_), init.d and a kernel with "privacy related network tweaks". 

## Warning about wannabe IT "experts"
Don't bother with the wannabe "IT-Pro" Mike Kuketz, that guy has no clue. In his [bullshit recommadation](https://www.kuketz-blog.de/afwall-wie-ich-persoenlich-die-android-firewall-nutze/) he disables IPv6 and then sets the privacy level for IPv6, which is pointless (because IPv6 is not active anymore). You do not need `/proc/sys/net/ipv6/conf/default/disable_ipv6` and `/proc/sys/net/ipv6/conf/wlan0/accept_ra` if you use `/proc/sys/net/ipv6/conf/all/disable_ipv6`, he juist blindly copied it. besides, that never worked under Android (_just saying_). To suggest to disable IPv6 is kind of studipd, because [IPv4 addresses are are now all been used](https://www.ripe.net/publications/news/about-ripe-ncc-and-ripe/the-ripe-ncc-has-run-out-of-ipv4-addresses). Back in 2017 this was already well-known btw. The first warning was given in 2015. There is nothing wrong with IPv6, just learn to configure it.

There is more to critize about this troll and his begging blog but I don't want to waste my time with him.


## Getting AFWall+
You can find AFWall+ [here](https://github.com/ukanth/afwall). And the downloadable version is avbl. over [here](https://f-droid.org/packages/dev.ukanth.ufirewall/). 


### Logging
You can capture the background connections via [Net Monitor](https://f-droid.org/packages/org.secuso.privacyfriendlynetmonitor/).


## Do not touch or allow the following resources

* `-10` - All apps
* `-1` (not visible) loopback and unknown tunneled traffic
* `-11` - Linux Kernel - Only enable it if you disabled "netd", the same goes for `0 - Root`
* `ADB` - ADB needs usually LAN only
* `1000 - System`
* `2000 - Linux shell`


## You should enable the following rules

* `-14: (NTP)`
* `-12: DHCP+DNS (Tethering)`
* `Media Server`
* `Downloads, Mass storage, Download-Manager`
* `VPN networking` - Assuming you use it, as well as `Phone` (if you use SIP/VoIP) and `SMS/MMS` assuming you use all of it
* `GPS` for A-GPS data e.g. Öffi app


##  netd VS. activated netd

### Deactivated netd needs the following activated

* 0: root
* -11: Kernel
* -12: Tethering (Wenn man das benötigt)

### Activated netd needs the following activated

* -12: Tethering (_optional_)
