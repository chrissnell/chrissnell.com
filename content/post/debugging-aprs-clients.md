+++
Categories = ["Nerd", "Ham Radio"]
Description = "Debugging APRS clients with socat and tnc-server"
Tags = ["Nerd", "Ham Radio", "Software"]
date = "2014-08-10T00:00:00-08:00"
menu = "main"
title = "Debugging APRS clients with a virtual null-modem cable using socat and tnc-server"

+++
While working on my [GoBalloon](http://github.com/chrissnell/GoBalloon) project, I found myself needing to connect two AX.25/KISS APRS clients together for debugging purposes. &nbsp; If your computer has two hardware RS-232 serial ports, you can accomplish this by connecting a null modem cable between the two ports and connecting an APRS client to each port. &nbsp; I discovered an easier way to do this today and you don't even need a serial port at all. &nbsp; The trick is to use the **socat** utility. &nbsp;socat is available in most Linux distros and there are a few Windows ports out there, as well.

To create the virtual null modem cable, run socat like this:

{{< highlight shell-session >}}
% socat -d -d pty,raw,echo=0 pty,raw,echo=0

2014/08/10 19:08:28 socat[25083] N PTY is /dev/pts/3
2014/08/10 19:08:28 socat[25083] N PTY is /dev/pts/4
2014/08/10 19:08:28 socat[25083] N starting data transfer loop with FDs [3,3] and [5,5]

{{< /highlight  >}}


As you can see above, socat will respond with two virtual serial ports (ptys). &nbsp;In the example above, they are /dev/pts/3 and /dev/pts/4.

Once you have those, simply fire up your APRS clients and connect each of them to one of those virtual ports. &nbsp; Everything sent by one client will be copied to the other client and vice-versa.

If you are debugging an APRS client that uses KISS-over-TCP, you can use my [tnc-server](http://github.com/chrissnell/tnc-server) utility to bridge the virtual serial port and the network. &nbsp;Simply tell tnc-server to attach to one of those virtual ports and it will open a network listener that you can connect your KISS-over-TCP client&nbsp;to:

{{< highlight shell-session >}}
./tnc-server -port=/dev/pts/3 -listen=0.0.0.0:6700
{{< /highlight  >}}

&nbsp;If you want to attach two KISS-over-TCP clients to each other, simply fire up a second instance of tnc-server that listens on a different port.

{{< highlight shell-session >}}
 ./tnc-server -port=/dev/pts/4 -listen=0.0.0.0:6701
{{< /highlight  >}}

From there, connect one APRS client to &nbsp;&lt;your_machines_IP&gt; &nbsp;port 6700 and the other client to port 6701.
