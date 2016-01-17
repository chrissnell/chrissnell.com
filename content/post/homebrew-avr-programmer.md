+++
Categories = ["tech", "home", "avr", "arduino"]
Description = "Homebrew AVR Programmer"
Tags = ["avr", "nerd", "tech"]
date = "2012-12-01T00:00:00-08:00"
menu = "main"
title = "Homebrew AVR Programmer"

+++
I finally got around to building a little&nbsp;[Atmel AVR](http://en.wikipedia.org/wiki/Atmel_AVR)&nbsp;chip programmer using some perfboard and a ZIF socket. &nbsp; Using&nbsp;[CrossPack's](http://www.google.com/url?sa=t&amp;rct=j&amp;q=&amp;esrc=s&amp;source=web&amp;cd=1&amp;ved=0CC8QFjAA&amp;url=http%3A%2F%2Fwww.obdev.at%2Fproducts%2Fcrosspack%2Findex.html&amp;ei=daq5UKbAGKK6yQG_24GoBA&amp;usg=AFQjCNGYKbcitvOX-SQpY9TlxHGJIQwjzg)&nbsp;gcc cross-compiler, I can now compile for the AVR chips on my Mac and burn them directly to the chip without using a Linux or Windows VM.

I designed the programmer so that it can handle ATtiny25/45/85/2313 and ATmega48/88/168/328 chips, all in the same ZIF socket. &nbsp;Spiffy.

{{< figure src="/images/post/avr_top.jpg" >}}
{{< figure src="/images/post/avr_bottom.jpg" >}}

My programmer connects to the Mac via a&nbsp;[Pocket AVR Programmer](https://www.sparkfun.com/products/9825)&nbsp;from Sparkfun.

For what it's worth, here is how I burn a compiled .hex image to an ATtiny2313 chip:

<pre>avrdude -p attiny2313 -c usbtiny -U flash:w:FILENAME_TO_BURN</pre>

Here's an example how how I set the fuses on the chip:

<pre>avrdude -p attiny2313 -c usbtiny -U lfuse:w:0xe4:m -U hfuse:w:0xdf:m -U efuse:w:0xff:m</pre>
