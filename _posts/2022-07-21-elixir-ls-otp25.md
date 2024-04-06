---
title: Getting elixir-ls to work with Erlang OTP 25
date: 2022-07-21
---

[Currently](https://github.com/elixir-lsp/vscode-elixir-ls/issues/255#issuecomment-1164017751) elixir-ls dialyzer does not work with OTP 25 and you can either downgrade to OTP 24 and wait for the fix, or build your own version of `vscode-elixir-ls`.

<!--more-->

And, this is exactly what I did -- built it with OTP 25, or to be precise:

```
$ cat .tool-versions
erlang 25.0.2
elixir 1.13.4-otp-25
```

You can get the prebuilt version for Apple M1 right here: https://0x7f.dev/media/elixir-ls-0.10.0-otp25.vsix

SHA256 checksum: `05f5bd7ec2a66d712b225c5db6a65557e7e5013e3787e45943e2b39daf04b0de`

## Installation

**Note:** be sure to remove elixir-ls extension and restart Visual Studio Code/VSCodium

```
$ curl -O https://0x7f.dev/elixir-ls-0.10.0-otp25.vsix
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 2617k  100 2617k    0     0   172M      0 --:--:-- --:--:-- --:--:--  511M

$ sha256sum elixir-ls-0.10.0-otp25.vsix
05f5bd7ec2a66d712b225c5db6a65557e7e5013e3787e45943e2b39daf04b0de  elixir-ls-0.10.0-otp25.vsix

$ code --install-extension elixir-ls-0.10.0-otp25.vsix
```
