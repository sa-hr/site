---
title: "Creating new keyboard layouts"
date: 2013-08-24
---

Need for this came with the need for a new school laptop. In November this year I am traveling to Zürich, Switzerland and I will be buying my girlfriend an myself a new MacBook Airs for school. Now we all know that "third" world countries like Croatia tend to price up all products known to people so we decided to save up some money for future use and buy our laptops there. Even with an airplane ticket, room for two you still save up quite a lot!

Boom! Surprise, well not really but we didn't think about this before, they don't use the same keyboard layout as we do! Deal breaker worth 1000€? Nope. I created my own mix from two keyboards. What were the prerequisites?, I hear you ask.

1. To have our local letters on it: Č, Ć, Ž, Š, Đ
2. To not be so different form the printed layout on the actual keyboard
3. To have the @ sign placed at it's own key and the same thing for `

I installed [Ukulele](http://scripts.sil.org/cms/scripts/page.php?site_id=nrsi&id=ukelele), a very old software that still works and does the job with so much ease that this was kind of fun to do! I also created a swell little icon for the keyboard in case you like to have the language icons showing.

The manual and readme you can find on the [projects gist page](http://git.io/w8-aCg), or down below. And now the obligatory gif (/ˈdʒɪf/) featuring the keyboard layout with all of its modifiers:

![Animated layout](/swiss_croatian_anim.gif)

##Installation procedure

1. `mkdir ~/Library/Keyboard\ Layouts` (don't worry if folder already exists)
2. `cd ~/Library/Keyboard\ Layouts`
3. `wget http://git.io/fIhuTQ --no-check-certificate`
4. `wget http://0x7f.dev/Swiss_Croatian.icns`
5. Log out and log back in
6. Add the keyboard using the `Language & Text` menu from `Settings`
7. **DONE**
