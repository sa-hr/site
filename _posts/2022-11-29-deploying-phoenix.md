---
title: Deploying Phoenix apps on bare metal
date: 2022-11-29
---

I run a couple of internal and public applications written in Phoenix on our infrastructure. While services like [fly.io](https://fly.io) exist and are amazing, sometimes it's both cheaper (and more secure) to run small internal applications on your own hardware. It's certainly more fun. Thru the years I've developed my own process of deploying the application and this post will document the current procedure.

<!--more-->

I'm open to comments and I would love to hear your thoughts -- so please write to me andrei(a)0x7f.dev.

## Requirements

Since we are not using Docker the system requirements are fairly low for a normal sized app. I run everything in LXD containers, but a more conventional KVM VM can be used as well, it shouldn't really matter.

- 512 MB of RAM (I find that for the first build it's beneficial to have at least 1 GB, which I scale down later)
- 1 CPU with 1 socket
- 8GB of disk space (if you need more mount a SMB or NFS share)
- a database (I host one Postgres instance for all apps)

## Initial setup

My OS of choice is Ubuntu 20.04, but I'm slowly switching to Alpine Linux. The biggest hurdle for me personally is lack of SystemD (I know - blasphemy; but it's easy and it works). Once the OS is installed I run:

```shell
$ apt update
$ apt install vim git curl unzip libssl-dev make automake autoconf libncurses5-dev gcc
$ git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.10.2
$ echo ". \$HOME/.asdf/asdf.sh" >> .bashrc
$ source .bashrc
$ asdf plugin add elixir
$ asdf plugin add erlang
```

And now we can setup the application deployment and startup.

```shell
$ git init --bare app
```

Then, on your local machine add a new origin to the repo `git origin add prod user@server:app` and push `git push prod`. This will get your app on the server and will be the way of deploying your app. But first we need to do some manual work!

Back on your server:

```shell
$ git clone app/ release
$ cd release
$ asdf install
$ mix deps.get --only prod
$ MIX_ENV=prod mix compile
```

Now we setup our `.env` file:

```shell
$ cat > .env << EOF
SECRET_KEY_BASE=<SOME KEY>
DATABASE_URL=ecto://user:password@db_host/db
MIX_ENV=prod
EOF
```

And we can setup the SystemD service:

```shell
$ cat > /etc/systemd/system/app.service << EOF
[Unit]
Description=App
After=network.target

[Service]
EnvironmentFile=/root/release/.env
WorkingDirectory=/root/release
ExecStart=/root/release/_build/prod/rel/<App name>/bin/<App name> start
ExecStop=/root/release/_build/prod/rel/<App name>/bin/<App name> stop
User=root
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
$ systemctl daemon-reload
$ systemctl enable app
```

The app can't be started just yet, we still need to cut the first release! The easiest way I found was to add the deploy script and force push the existing commit so it triggers:

```shell
$ cat > /root/app/hooks/post-receive << EOF
#!/bin/bash
TARGET="/root/release"
GIT_DIR="/root/app"
BRANCH="master"

while read oldrev newrev ref
do
  if [ "$ref" = "refs/heads/$BRANCH" ];
  then
    source $HOME/.asdf/asdf.sh
    echo "Ref $ref received. Deploying ${BRANCH} branch to production..."
    git --work-tree=$TARGET --git-dir=$GIT_DIR checkout -f $BRANCH
    cd $TARGET
    export $(xargs < .env)

    mix deps.get --only prod
    mix compile
    mix phx.digest
    mix release --overwrite
    mix ecto.migrate
    systemctl restart app
  else
    echo "Ref $ref received. Doing nothing: only the ${BRANCH} branch may be deployed on this server."
  fi
done
EOF
$ chmod +x /root/app/hooks/post-receive
```

And on your computer:

```shell
$ git commit --amend --no-edit
$ git push -f prod
```

And that's it, this should recompile, create a digest, and setup a release. After it's done it will restart the app (and that will actually start it for the first time).

## Next steps

If you want, you can now setup a reverse proxy (like nginx, caddy, or haproxy) with SSL, but that's outside of the scope of this guide.
