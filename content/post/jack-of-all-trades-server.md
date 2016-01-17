+++
Categories = ["tech", "home", "pfSense"]
Description = "The Jack-of-All-Trades Home Server"
Tags = ["pfSense"]
date = "2013-12-31T00:21:57-08:00"
menu = "main"
title = "The Jack-of-All-Trades Home Server"

+++

I've been wanting to build a server for my home for a while and I finally got around to it over the holidays. &nbsp; My goal was to ditch all of the aging equipment in my office and consolidate it into one powerful, do-it-all machine. &nbsp;It took several days of hacking to get it all working but now it lives:

{{< figure src="/images/post/server.jpg" title="The Server" >}}

**Consolidation**

Before this server, I had a bunch of old, crap hardware running in my office. &nbsp;The gear was a decade old and couldn't keep up with modern Internet speeds and the new applications. &nbsp; I decided to use VMware's (free!) [ESXi hypervisor](http://www.vmware.com/products/vsphere-hypervisor/overview.html) to consolidate all of this old junk onto one box. &nbsp; Onto this one server, I consolidated:

*   Software development server ([Ubuntu Linux](http://www.ubuntu.com/))
*   Password+Wireless cracking/Security server ([Backtrack Linux](http://backtrack-linux.org/))
*   Media server ([FreeBSD](http://freebsd.org))
*   Firewall + VPN ([pfSense](http://www.pfsense.org))&nbsp;

To run all of these things and run them well, I needed some big iron. &nbsp;Here's what I built:

*   [Supermicro X9SRH-7F](http://www.supermicro.com/products/motherboard/xeon/c600/x9srh-7f.cfm) server-class motherboard
*   Intel Xeon E5-2620 hex-core server-class CPU
*   32 GB Kingston DDR3 1600 MHz ECC RAM
*   4 x 2 TB Western Digital "Red" server-class hard disks (RAID 10)
*   [Gigabyte/AMD Radeon HD7970](Gigabyte/AMD%20Radeon%20HD7970) video card (for GPU-assisted password cracking, more on that later...)
*   Intel I340-T4 quad-port 1000 Mbit ethernet adapter (PCIe)
*   Corsair HX1050 power supply (1050 Watt)
*   Supermicro CPU heatsink for narrow-profile LGA2011 CPU
*   Corsair 600T mid-tower case

This machine is a monster. &nbsp; Even running all of these virtual servers, its resources aren't even 10% utilized.

**The Firewall**

My old firewall was a Soekris net4801 appliance (circa 2003) running m0n0wall. &nbsp;It protected my home network for ten years, never once crashing. &nbsp; The only real problem with it was that it can no longer keep up with modern home Internet speeds. &nbsp;

{{< figure src="/images/post/soekris.jpg" title="Soekris net4801" >}}

These days, we have a 35 Mbps connection at the house but the Soekris tops out at a little over 21 Mbps. &nbsp;When it maxed out its power, packets would drop and the Internet got flakey. &nbsp;I wanted something that could handle 100+ Mbps with ease. &nbsp; This new machine, with its four-port server-grade Intel NIC was the ticket. &nbsp;With a tiny 1 VCPU, 1 GB VRAM virtual machine running pfSense, I can now push data as fast as Comcast will allow.

The old Soekris firewall:

{{< figure src="/images/post/speedtest_soekris.jpg" >}}

The new, virtualized pfSense firewall:

{{< figure src="/images/post/speedtest_pfsense.jpg" >}}

The trickest part about running a firewall under ESXi is getting the networking correct. &nbsp;The best (and in my opinion, most secure) way to do this is to use dedicated NICs for each network. &nbsp;I use one port for my WAN (cable modem) and another for the LAN (internal private network). &nbsp; I have another network, the DMZ, for servers that I don't trust enough to run on the private network. &nbsp;The Backtrack Linux VM goes here. &nbsp;I use ESXi's virtual switching to connect VMs to NICs:

{{< figure src="/images/post/vSwitch.jpg" >}}

The arrangement works well. &nbsp;I get great throughput on the firewall and moving a machine between networks takes only a couple of mouse clicks.

**Backtrack Server (My Very Own Evil Mad Scientist Laboratory)**

{{< figure src="/images/post/backtrack-linux-logo.png" >}}


I've been playing around with [Backtrack Linux](http://backtrack-linux.org) for a while now. &nbsp;For those that don't know, Backtrack is a Linux operating system designed for electronic security work. &nbsp; It comes with a massive selection of exploitation, forensics, snooping, and analysis tools pre-installed. &nbsp;If you were so inclined, Backtrack has most of what you need to break into networks and cause major havoc. &nbsp;For its more altrustic users, it's a outstanding toolkit to test your network's security. &nbsp; Ever wonder if someone can crack your WiFi key and snoop around on your home PC? &nbsp;Backtrack has the tools you need to find out. &nbsp;By running exploits against your own network and understanding its vulnerabilities, you can better secure your data.

One of my favorite tools on BT is [Pyrit](http://code.google.com/p/pyrit/). &nbsp;Pyrit is an open-source password cracker capable of cracking WEP, WPA, and WPA2 passwords for WiFi networks. &nbsp;The superhero power of Pyrit is its ability to use your computer's graphics card (GPU) to greatly accelerate the speed of password cracking. &nbsp; A good GPU (like my ATI HD7970) can test passwords _hundreds of times faster_ than the average PC CPU. &nbsp;With this kind of power, it's possible to bruteforce crack a password in a few days that might have taken years to crack on a conventional PC. &nbsp;On an even more sinister note, Pyrit allows you to cluster multiple GPUs running on multiple servers together, potentially creating a massive password-cracking machine. &nbsp; My ATI HD7970 is the fastest GPU available on the consumer market, yet it only costs $400 on Amazon. &nbsp; Can you imagine what a rogue state like North Korea could do if they got their hands on a few dozen of these cards? &nbsp; A security firm [recently clustered 25 GPUs together](http://www.techspot.com/news/51044-25-gpu-cluster-can-brute-force-windows-password-in-record-time.html) and achieved 350 billion password guesses per second--fast enough to crack **any** Windows password in five and a half hours. &nbsp; Very powerful stuff. &nbsp; Very scary. &nbsp;I had to build my own.

The biggest challenge I faced in my project was getting the HD7970 to be available to my Backtrack virtual machine. &nbsp; ESXi provides a mechanism called "pass-thru" that lets you designate a VM to control a device like a GPU. &nbsp; Unfortunately, the mechanism is poorly documented and I spent several days experimenting before I got it to work. &nbsp; In the end, I had to enable pass-thru for the GPU devices and I had to add a line into the VM's .vnx file:

`pciHole.start = "2853"`

I won't go into the particulars of how I determined this value but you can find it if you Google around. There's a procedure for editing .vnx files that you'll need to follow. Again, Google it. &nbsp; Once you get the hole "punched" and pass-thru working, you'll need to install the ATI drivers and SDK on the VM. &nbsp; The biggest problem I ran into is that the newest version of the SDK is needed to support this card, but this newest version is missing some critical libraries that are necessary to get [CAL++](http://calpp.sourceforge.net/) and OpenCL working. &nbsp; What I did was install the older (more complete) SDK and then installed the newest version on top of that, which gave me everything I needed. &nbsp; I also had to install the beta release of the ATI drivers because they're the only version that supports the HD7970. &nbsp;Finally (and this was a big, big stumper for me), I realized that I had to be actually running the Xorg X11 server (i.e. displaying a desktop on a monitor) for CAL++ and Pyrit to be able to "see" the GPU. &nbsp;(Sorry for the tangent there, but I put all that in there to help the next guy who tries to do all of this.)

Once the GPU is working under Backtrack, you can run Pyrit's benchmark and see some dramatic numbers:

{{< figure src="/images/post/btlinux_desktop.jpg" title="The Backtrack Linux desktop" >}}

That first benchmark is my GPU. &nbsp; As you can see, it's over 200x faster than the cores in my server's Intel CPU.

**Future Possibilities**

My server is not yet perfect. &nbsp;Of all simple things, I haven't yet figured out how to pass my motherboard's USB controller through to the VM, so I can't use a mouse or USB keyboard. &nbsp;Unable to attach my mouse to Backtrack, I eventually came up with the idea to use [Synergy](synergy-foss.org/) to share my Mac Pro's mouse and keyboard with the X11 server on the BT VM. &nbsp; Since USB isn't working, I can't attach my Alfa AWUS036H USB wireless adapter to the Backtrack machine, so I can't directly capture WiFi packets on the VM. &nbsp; Instead, I have to use my Macbook Pro to capture the traffic and manually copy the pcap files to the BT VM. &nbsp; In the future, I plan on setting up an IPsec VPN for the house and using the VPN to allow me to access the power of the big GPU from wherever I am in the field. &nbsp; I might even be able to get Pyrix clustering working over the VPN.

The ESXi platform gives me great flexibility for future expansion. &nbsp; If an operating system can run on a modern PC, it can probably run virtualized under ESXi. &nbsp; If I ever have a need for it, I might fire up another VM and install Windows Server for my home network. &nbsp;ESXi can even run Mac OS X! &nbsp;I'm super-happy with my decision to consolidate and I'm loving my much-less-cluttered office.
