# AFWall+ Tweak

Your Android OS needs (_iptables, if not integrated_), init.d and a kernel with "privacy related network tweaks". 

## Warning about wannabe IT "experts"
Don't bother with the wannabe "IT-Pro" Mike Kuketz, that guy has no clue. In his [bullshit recommadation](https://www.kuketz-blog.de/afwall-wie-ich-persoenlich-die-android-firewall-nutze/) he disables IPv6 and then sets the privacy level for IPv6, which is pointless (because IPv6 is not active anymore). You do not need `/proc/sys/net/ipv6/conf/default/disable_ipv6` and `/proc/sys/net/ipv6/conf/wlan0/accept_ra` if you use `/proc/sys/net/ipv6/conf/all/disable_ipv6`, he juist blindly copied it. besides, that never worked under Android (_just saying_). To suggest to disable IPv6 is kind of studipd, because [IPv4 addresses are are now all been used](https://www.ripe.net/publications/news/about-ripe-ncc-and-ripe/the-ripe-ncc-has-run-out-of-ipv4-addresses). Back in 2017 this was already well-known btw. The first warning was given in 2015. There is nothing wrong with IPv6, just learn to configure it.

* Calling [NetGuard a "alternative" to AFWall+ is so wrong](https://www.kuketz-blog.de/afwall-wie-ich-persoenlich-die-android-firewall-nutze/), AFWall+ is a GUi for iptabes while NetGuard uses Android's own VPN interface (which leaks traffic on it's own and is vulnerable).
* You can "overwrite" DNS all day long with iptables, this does not help if providers like Vodafone interfering with the APN (_just saying_). 
* Proprietary has nothing to do with been "intransparent", you basically assume automatically now that every closed source app is malware. There are many examples when open source did not helped like OpenSSL and no one gave a shit because auditing and seen the source are two differnt things. Threema is closed source, well documented and audited (just one app example).
* Android itself does not connect to the internet on it's own, pre-installed apps usually doing it without user consent. Do not mix "certificate updates", NTP and other "security" mechanism with "spying".

There is more to critize about this troll and his begging blog but I don't want to waste my time with him. 


## Getting AFWall+
You can find AFWall+ [here](https://github.com/ukanth/afwall). And the downloadable version is avbl. over [here](https://f-droid.org/packages/dev.ukanth.ufirewall/). 


### Logging
You can capture the background connections via [Net Monitor](https://f-droid.org/packages/org.secuso.privacyfriendlynetmonitor/). AFwall+ internal logger is far away from been "good".


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


##  Disabled netd VS. activated netd

### Deactivated netd needs the following activated

* 0: root
* -11: Kernel
* -12: Tethering (Wenn man das benötigt)

### Activated netd needs the following activated

* -12: Tethering (_optional_)
