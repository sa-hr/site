---
title: Framework 13 Review 
date: 2024-06-08
---

Following [DHH](https://x.com/dhh)'s (with whom I do not agree very often) trip to Linux on desktop land, and deciding to see if _"This is the year of Linux desktop"_, I decided to switch to Linux full-time for development and life.

First, I started my journey with an old ThinkPad, nicknamed Shitbook. While being an old and slow device, I enjoyed developing and working on it a whole bunch. That gave me the final push to order a Framework.

I decided on Framework since it looked (and looks) like a future-proof decision. I can always just upgrade the processor board or the screen without having to buy a new device altogether. It gave me this feeling I had as a kid saving up for RAM sticks and a bit larger HDD. Let's see if it stands the test of time.

Last thing to note, I'm not a novice Linux user. But still, having used macOS for my work machine for the past 10(!!!) years, I expected this switch to be hella hard.

<figure>
  <img src="/laptop_framework.jpeg" alt="My new laptop - Framework 13" />
  <figcaption>My new laptop - Framework 13</figcaption>
</figure>


## Ordering process

This was the largest hurdle. Framework does not ship to Croatia, so I had to go through my friend [Oliwer](https://oliwer.me/) in Poland so I could even order the device.

The laptop got to him in five days, and then to me in another five. The shipping ended up being around 40 euros, which I guess is not that bad. The upside is that the marketplace ships to Croatia. And to make things even more complicated, they fulfill from Taiwan, so even fewer reasons to just ship to Croatia.

Next thing was getting RAM and SSD. I wanted a 96 GB kit, but I could not find one for a reasonable price. In the end, I ended up with:

- WD_BLACK SN850X NVMe SSD 1TB @ 78.63 euros
- Crucial RAM 64GB Kit (2x32GB) DDR5 5600MHz @ 203.76 euros

Prices above are without VAT.

The total price of the laptop was, in the end:

| | Item | Price |
|-|------|-------|
|1|Framework 13 AMD 7840U | 1,700.00 euros |
|2|Shipping to Croatia | 38.50 euros |
|3|1TB SSD | 78.63 euros |
|4|64GB DDR5 | 203.76 euros |
| | **TOTAL** | 2,020.89 euros |

The module configuration for ports I got was: 2x Type-C, 1x USB A, 1x HDMI.

In the future, I plan on getting a microSD port and Ethernet.

## Build quality

Putting this device together was a breeze. The whole laptop came in a bit distorted and warped (but just a tiny bit). Which I just forced into place with my hands, no damage or issues really.

A couple of screws for the base, and that part was done. The only gripe I have is really the screen bezel. It does not fit the best and you can hear it creak every once in a while. But I'm just saying this to say something.

No complaints really.

## Setup

I chose Fedora with Gnome for my OS. I chose well, at least for now. Regarding Framework, the only thing I really had to do was update the firmware, which took about 5 minutes total.

On the first power-up, it does something called memory training (never heard of this before), and that was done without any user feedback that I can remember. I didn't like that :).

## Day to day usage

I'll do a follow-up post to this one once a little time passes. But for now, a few key points:

- I had some issues with my external monitor. The first one I tried I used a Lenovo docking station that uses DisplayLink. After installing the driver, it made my CPU pin at 60% while using the device with 4k@100Hz. I switched to another monitor that is 4k@60Hz and connected via Type-C to the device. This solved that issue.
- Battery life. This one I have to adjust to as on Macs it's like magic. But seeing as I do not work away from power outlets most of the time, this won't really be an issue.
- This thing is powerful. OMG. I had an M2 Pro Mac before, and this compares very, very well.
- My editor of choice, [Zed](https://zed.dev/), does not have an official Linux build yet, so I switched to Neovim for a while.

## A little bit on Linux for a desktop

Linux is ready for the desktop. But not if you do not know what you're doing. I had to solve some issues that I didn't even notice that I solved. And tweaking Gnome is easy in theory, while in practice most users will be confused.

Not to say that I'm smart or anything, it's just years of experience at this point. I am not sure if I would have been able to do this switch even 3-5 years ago.

We as a community have a long way to go still in order to bring Linux to normal users. We at [HrOpen](https://open.hr) are doing our part.

## Closing words

I will write more on this as time goes. But so far I rate the whole thing a solid **7/10**. It did not slow me down, and everything works with not a lot of setup. (Well, I didn't have to compile anything just yet, except Erlang)

I had larger influencers than DHH for this. At a meetup, I saw [Saša Jurić](https://www.theerlangelist.com/) rocking Linux. That was the first tipping point for me. I knew Erlang and Elixir development must be nice if he is there :).
