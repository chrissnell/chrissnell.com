+++
Categories = ["Nerd"]
Description = "Stop piping curl to /bin/sh"
Tags = ["Sysadmin", "UNIX", "Dumb Shit"]
date = "2013-12-24T00:00:00-08:00"
menu = "main"
title = "Stop piping curl to /bin/sh"

+++
I've noticed a trend lately where software developers ask you to pipe the output of a HTTP GET to a shell to install their software. &nbsp;It's certainly convenient for the inexperienced shell user who might not be comfortable with Apt or Homebrew; never mind that we spent the late 1990s and 2000s building these tools that make it easy to install software! &nbsp;The pipe-to-shell method is definitely the new hotness but this idiotic method has been around for a while. &nbsp; When I was a clueless freshman at Vanderbilt in 1993, I used this technique install an IRC client on a SunOS machine in the computer lab like a total noob:

{{< highlight shell-session >}}
 telnet&nbsp;sci.dixie.edu&nbsp;1 | sh&nbsp;
{{< /highlight  >}}

At the time, I had no idea what that command did and I happily ran it. &nbsp; Did it install a backdoor into my account on the VUSE systems? &nbsp;Maybe. &nbsp;It would have been ridiculously easy for the Dixie admins to do that. &nbsp; It was a pretty spiffy shar(1) archive that packaged up some binaries and shell scripts in a uuencoded shell package. &nbsp;All I knew is I ran that command and a bunch of shit scrolled across my screen for a few minutes and when it was done, I had an IRC client and I was happy. &nbsp;

Sure, you could fetch the URL in your browser first and review the shell script but will most people do this? &nbsp; How good are you at quickly reading a shell script? &nbsp; Could you spot a well-hidden backdoor, a little bit of obfuscation tucked away in the middle of a huge regex?

The pipe-to-shell technique is showing up more and more these days. &nbsp;RVM uses it...

{{< figure src="/images/post/curlsh_rvm.jpg" >}}

So does CopperEgg...

{{< figure src="/images/post/curlsh_copperegg.jpg" >}}

pip uses a variation of this--only slightly less degenerate--where they ask you to download and execute some Python...

{{< figure src="/images/post/curlsh_pip.jpg" >}}

To be fair, pip is also available through popular package managers but they're still pushing this method first to new users.

Why are we doing this? &nbsp;It's terrible from both security and maintainability perspective. &nbsp; If a committer of one of these popular software packages gets their desktop 0wned, the users of their software might very well get rootkits installed on their servers without their knownlege.

What's so wrong with good old apt and yum? &nbsp;Unlike the pipe-to-shell method, these repositories have measures in place to authenticate packages and the very nature of a package allows the sysadmin to cleanly uninstall it at a later date.

Please stop piping curl(1) to sh(1) before it really [becomes a thing](https://www.youtube.com/watch?v=nG-4p4Er3VY).
