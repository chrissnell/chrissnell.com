+++
Categories = ["Nerd", "Linux", "IPv6"]
Description = "Debugging APRS clients with socat and tnc-server"
Tags = ["Nerd", "Linux", "IPv6"]
date = "2016-12-17T00:00:00-08:00"
menu = "main"
title = "Detecting IPv6 clients on a static site with nginx"

+++
This blog is IPv6-friendly and if you look over on the left sidebar, you might notice
a special greeting if you've visiting this site over IPv6.  The site is completely
static, generated using [Hugo](https://gohugo.io/), so I'm employing a small nginx+CSS
trick to make this work.

To do something similar for your site, you'll first need to create a HTML element and
give it a unique class, like ```ipv6-detect```:

{{< highlight html >}}
<div class="ipv6-detect">
  Thanks for visiting over IPv6.
</div>
{{< /highlight >}}

Next, you need to create two CSS files in your document root, one for IPv4 users
and one for IPv6 users.  For example:

In /css/ipv6.css:
{{< highlight css >}}
/* Anything with this selector will be displayed on the page */
.ipv6-detect {
    display: block;
}
/* Anything with this selector will be hidden from the page */
.ipv4-detect {
    display: none;
}
{{< /highlight >}}

and in /css/ipv4.css:
{{< highlight css >}}
/* Anything with this selector will be hidden on the page */
.ipv6-detect {
    display: none;
}
/* Anything with this selector will be displayed on the page */
.ipv4-detect {
    display: block;
}
{{< /highlight >}}

Now, we need to include the CSS in our HTML but we're going to do it a little differently.
We're going to include only /css/ipv6.css and we're going to rely on nginx to switch
out the ipv4.css file for IPv4 clients.

{{< highlight html >}}
<link rel="stylesheet" href="/css/ipv6.css">
{{< /highlight >}}


Finally, we just need to configure nginx to serve the correct file to the user.

In your nginx.conf (or site configuration file):

{{< highlight nginx >}}
# Force the "Cache-Control: no-cache" header when serving these CSS files.
# This keeps the client from caching them and displaying the wrong thing
# if they switch IPs from v6 to v4 or vice-versa in the future.
location ~ ^/css/(ipv6|ipv4)\.css {
   expires -1;
}

# Check $remote_addr for something that looks like an IPv4 IP.  It's a
# lame regex that's not perfect but good enough to deal with the already-
# clean IP addresses that come in $remote_addr.
if ($remote_addr ~* "^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$") {
   # This appears to be an IPv4 client, so we send them the ipv4.css instead.
   rewrite ^/css/ipv6.css$ /css/ipv4.css break;
}
{{< /highlight >}}
