---
title: "Hubot on Campfire with Heroku"
date: 2013-08-08
---

Setting up Hubot should be a piece of cake, but sometimes it can be time consuming. But after spending my day in trial and error I finally did it without much problems after all. First things first, this is what you will need in advance:

1. Campfire account (free or paid) for you _and_ for your bot
2. Heroku account (enter payment information up front in settings)

## Dependencies

You will need installed: git, ruby, node.js and npm. If you are reading this there is a good chance that you already have git installed and for ruby the stars look good too. So you will need to install the last two.

First of all you will have to install Heroku gem application (or script?):

    gem install heroku

Next using brew you will install node.js:

    brew install node

And for the end install npm:

    curl http://npmjs.org/install.sh | sh

And now for the star of the show, we install hubot along with coffeescript using npm:

    npm install -g hubot coffee-script

Done, we have everything installed!

## The actual setup

When we have every thing up and running we will create our own hubot! Now navigate to some folder that you won't delete in your spring cleaning after a month and run:

    hubot --create myhubot

(Replace myhubot with your own name for it.) This will create a folder with your own name and robot. Now for last few touches. Edit the Procfile in the folder and replace several parts to make this as good working as possible.

`web: bin/hubot -a campfire -n Hubot`

Replace `web` with anything else than app (it can be your robots name) and then replace `Hubot` with your robots name. Now the application, once it is on Heroku, will operate as intended.

## Deploying to Heroku

"Upload" to Heroku using git: (be sure that you are in the top directory of your hubot robot!)

    git init .
    git add .
    git commit -m "initial commit"

Now create your Heroku application, replace `hubot` again with your robots name.

    heroku create hubot --stack cedar

And then push the directory to heroku:

    git push heroku master

Also since some scripts use Redis it is a good idea to install it now on Heroku. This is still free!

    heroku addons:add redistogo:nano

Done!

## Configuration (last step)

You will need the API key from the robots Campfire account settings, room IDs that you want your hubot to listen in (found in the URL of rooms) and your domain username eg. `username`.campfire.com. Also you will make your user the admin of the bot. Enter this commands one by one. Replace the examples with your own data.

    heroku config:add HUBOT_CAMPFIRE_TOKEN=apikey
    heroku config:add HUBOT_CAMPFIRE_ROOMS=roomnumber
    heroku config:add HUBOT_CAMPFIRE_ACCOUNT="username"
    // Be sure to enter your name exactly how it is in Campifre, with capitals and spaces, and everything!
    heroku config:add HUBOT_AUTH_ADMIN="Your Name"

## Running the robot

Now we are almost at the end enter the room that you told your robot to be in and enter this last few commands: (Remember to use your own proccess name form "The actual setup" instead of process!)

    heroku ps:scale process=1

And check if the robot is running: `heroku ps`. You are done! If you have any questions don't hesitate to ask me in the comments or however you want. Your robot should be joining your room and now you can script him, or use him as he is. Have fun.

---

I used this great resources to compile my own tutorial:

- [martinciu.com/2011/11/deploying-hubot-to-heroku-like-a-boss.html](http://martinciu.com/2011/11/deploying-hubot-to-heroku-like-a-boss.html)
- [github.com/github/hubot/blob/master/docs/README.md](https://github.com/github/hubot/blob/master/docs/README.md)
