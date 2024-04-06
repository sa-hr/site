---
title: NTP Implementation in Elixir
date: 2023-07-15
---

## The idea

So everything started off with the idea that I can somehow fake uptime of a machine by updating the time against a "corrupted" NTP that will lie about the time. Since there isn't such a thing as a lying NTP server I decided to create one.

This will be an exercise in reverse engineering a protocol, some Linux command line tricks, bitstring manipulation in Elixir, and some various other tricks.

## Discovering NTP

I'm using a M1 Macbook so I needed an x86 Linux VM. I downloaded OrbStack[^1] and started an Ubuntu 22.04 machine. Next up we will need a couple of things installed on the machine so we can: 1. update the time against a known working NTP server, and 2. capture that network traffic.

```bash
$ sudo apt install tcpdump ntpdate
$ # Next start our network package capture in background
$ sudo tcpdump udp -w output.pcap &
[1] 2272
$ # And now we update the time
$ sudo ntpdate -u ntp.ubuntu.com
15 Jul 16:31:21 ntpdate[2273]: adjust time server 185.125.190.58 offset +0.113190 sec
```

Cool! Now all we have to do is stop the tcpdump:

```bash
$ kill 2272
56 packets captured
56 packets received by filter
0 packets dropped by kernel
```

Now we can explore around the `pcap` file. There is two ways we're going to explore today, one is with `tcpdump`, and the other one is with Wireshark[^2].

### Exploring our `pcap` file with `tcpdump`

```bash
$ tcpdump -qns 0 -X -r output.pcap
```

This will produce quite an output:

<details>
    <summary>Output</summary>
    <pre style="color:#586e75;background-color:#eee8d5;-moz-tab-size:2;-o-tab-size:2;tab-size:2;">
16:32:32.497588 IP 198.19.249.172.33489 > 198.19.248.200.53: UDP, length 43
  0x0000:  4500 0047 b63a 4000 4011 05cf c613 f9ac  E..G.:@.@.......
  0x0010:  c613 f8c8 82d1 0035 0033 7ee1 5368 0100  .......5.3~.Sh..
  0x0020:  0001 0000 0000 0001 036e 7470 0675 6275  .........ntp.ubu
  0x0030:  6e74 7503 636f 6d00 0001 0001 0000 2904  ntu.com.......).
  0x0040:  b000 0000 0000 00                        .......
16:32:32.497686 IP 198.19.249.172.33489 > 198.19.248.200.53: UDP, length 43
  0x0000:  4500 0047 b63b 4000 4011 05ce c613 f9ac  E..G.;@.@.......
  0x0010:  c613 f8c8 82d1 0035 0033 7ee1 eeec 0100  .......5.3~.....
  0x0020:  0001 0000 0000 0001 036e 7470 0675 6275  .........ntp.ubu
  0x0030:  6e74 7503 636f 6d00 001c 0001 0000 2904  ntu.com.......).
  0x0040:  b000 0000 0000 00                        .......
16:32:32.545195 IP 198.19.248.200.53 > 198.19.249.172.33489: UDP, length 193
  0x0000:  4500 00dd ada1 0000 3f11 4ed2 c613 f8c8  E.......?.N.....
  0x0010:  c613 f9ac 0035 82d1 00c9 0000 5368 8180  .....5......Sh..
  0x0020:  0001 0005 0000 0001 036e 7470 0675 6275  .........ntp.ubu
  0x0030:  6e74 7503 636f 6d00 0001 0001 036e 7470  ntu.com......ntp
  0x0040:  0675 6275 6e74 7503 636f 6d00 0001 0001  .ubuntu.com.....
  0x0050:  0000 004d 0004 b97d be39 036e 7470 0675  ...M...}.9.ntp.u
  0x0060:  6275 6e74 7503 636f 6d00 0001 0001 0000  buntu.com.......
  0x0070:  004d 0004 5bbd 5b9d 036e 7470 0675 6275  .M..[.[..ntp.ubu
  0x0080:  6e74 7503 636f 6d00 0001 0001 0000 004d  ntu.com........M
  0x0090:  0004 5bbd 5e04 036e 7470 0675 6275 6e74  ..[.^..ntp.ubunt
  0x00a0:  7503 636f 6d00 0001 0001 0000 004d 0004  u.com........M..
  0x00b0:  b97d be3a 036e 7470 0675 6275 6e74 7503  .}.:.ntp.ubuntu.
  0x00c0:  636f 6d00 0001 0001 0000 004d 0004 b97d  com........M...}
  0x00d0:  be38 0000 2904 b000 0000 0000 00         .8..)........
16:32:32.608719 IP 198.19.248.200.53 > 198.19.249.172.33489: UDP, length 169
  0x0000:  4500 00c5 ada2 0000 3f11 4ee9 c613 f8c8  E.......?.N.....
  0x0010:  c613 f9ac 0035 82d1 00b1 0000 eeec 8180  .....5..........
  0x0020:  0001 0003 0000 0001 036e 7470 0675 6275  .........ntp.ubu
  0x0030:  6e74 7503 636f 6d00 001c 0001 036e 7470  ntu.com......ntp
  0x0040:  0675 6275 6e74 7503 636f 6d00 001c 0001  .ubuntu.com.....
  0x0050:  0000 004d 0010 2620 002d 4000 0001 0000  ...M..&..-@.....
  0x0060:  0000 0000 0040 036e 7470 0675 6275 6e74  .....@.ntp.ubunt
  0x0070:  7503 636f 6d00 001c 0001 0000 004d 0010  u.com........M..
  0x0080:  2620 002d 4000 0001 0000 0000 0000 0041  &..-@..........A
  0x0090:  036e 7470 0675 6275 6e74 7503 636f 6d00  .ntp.ubuntu.com.
  0x00a0:  001c 0001 0000 004d 0010 2620 002d 4000  .......M..&..-@.
  0x00b0:  0001 0000 0000 0000 003f 0000 2904 b000  .........?..)...
  0x00c0:  0000 0000 00                             .....
16:32:32.725746 IP 198.19.249.172.36991 > 185.125.190.57.123: UDP, length 48
  0x0000:  4500 004c 6a77 4000 4011 98b2 c613 f9ac  E..Ljw@.@.......
  0x0010:  b97d be39 907f 007b 0038 37c1 e300 03fa  .}.9...{.87.....
  0x0020:  0001 0000 0001 0000 0000 0000 0000 0000  ................
  0x0030:  0000 0000 0000 0000 0000 0000 0000 0000  ................
  0x0040:  0000 0000 e85d 2c80 b9ab e514            .....],.....
16:32:32.757240 IP 185.125.190.57.123 > 198.19.249.172.36991: UDP, length 48
  0x0000:  4500 004c 40da 0000 3f11 0350 b97d be39  E..L@...?..P.}.9
  0x0010:  c613 f9ac 007b 907f 0038 0000 2402 03e7  .....{...8..$...
  0x0020:  0000 0044 0000 0017 c944 586a e85d 2bd7  ...D.....DXj.]+.
  0x0030:  9da3 dbc5 e85d 2c80 b9ab e514 e85d 2c80  .....],......],.
  0x0040:  beff 6d74 e85d 2c80 bf00 b637            ..mt.],....7
</pre>
</details>

We're going to cut it down into bite size pieces. First, we asked for time `ntp.ubuntu.com` which means we need to get the DNS record. We preform two DNS lookups one for `A` and one for `AAAA` record.

We know that by looking into the DNS protocol specification[^3], and seeing that we send `00 01` in order to get `A` and we send `00 1C` to get `AAAA`.

```
0x0030:  6e74 7503 636f 6d00 0001 0001 0000 2904  ntu.com.......).
                        ~~~~~^
```

and

```
0x0030:  6e74 7503 636f 6d00 001C 0001 0000 2904  ntu.com.......).
                        ~~~~~^
```

Next two packets are responses, which we can ignore. And now we have something that we need! The **request and response for NTP**. The first one we will have to parse and the second one we will have to create.

### Exploring the NTP request

This is the packet that we will dissect right now. While we do that let's also think about what could be interesting and think of a way to extract it in Elixir.

```text
16:32:32.725746 IP 198.19.249.172.36991 > 185.125.190.57.123: UDP, length 48
  0x0000:  .... .... .... .... .... .... .... ....  E..Ljw@.@.......
  0x0010:  .... .... .... .... .... .... e300 03fa  .}.9...{.87.....
  0x0020:  0001 0000 0001 0000 0000 0000 0000 0000  ................
  0x0030:  0000 0000 0000 0000 0000 0000 0000 0000  ................
  0x0040:  0000 0000 e85d 2c80 b9ab e514            .....],.....
```

We can ignore everything before `E3 00 03 FA`, as that's the IP header, and the protocol header.

Let's start with with the `E3`. That part of the request we call **flags** and to understand it we need to convert `E3` to binary: `11100011`. In that number we have three flags.

| bits  | Description                                                                      |
| ----- | -------------------------------------------------------------------------------- |
| `11`  | The first two bits represent the leap indicator[^4]. In this case it's `unknown` |
| `100` | The second three bits represent the NTP Version 4[^5]                            |
| `011` | Last two are the packet mode[^6], and in this case it's the client               |

Next up we have `00` which is a Clock stratum[^7] (source, GPS, atomic clock, etc.) and in this case it's set to 0 which means unspecified.

Next `03` is the pooling interval[^8], in this case it's set to three.

Following that we have three fields that specify the clock precision[^9], delay[^10] and dispersion[^11]: `FA 00 01 00 00 00 01 00 00`.

And finally we start getting into interesting and potentially useful things:

| bytes                     | Description              | Needed?                                                                   |
| ------------------------- | ------------------------ | ------------------------------------------------------------------------- |
| `00 00 00 00`             | Reference ID[^12]        | If set to something we need to return it. Currently `nil`.                |
| `00 00 00 00 00 00 00 00` | Reference timestamp[^13] |                                                                           |
| `00 00 00 00 00 00 00 00` | Origin timestamp[^14]    |                                                                           |
| `00 00 00 00 00 00 00 00` | Receive timestamp[^15]   |                                                                           |
| `E8 5D 2C 80 B9 AB E5 14` | Transmit timestamp[^16]  | This one is needed for comparison on the client side. We return it as is. |

So, looking at this we're only interested in `32` bits of the ID and last `64` bits. In Elixir this is very easy to extract with pattern matching:

```elixir
<<_::binary-size(12),
  id::binary-size(4),
  _::binary-size(24),
  origin_timestamp::binary-size(8)>> = request
```

In my implementation I hardcoded the ID so I use: `<<_::binary-size(40), origin_timestamp::binary>>`.

We're done with the request, now we need to look at the response.

### Exploring and building a response

As a starting point here is our response that we got from the working NTP server:

```text
16:32:32.757240 IP 185.125.190.57.123 > 198.19.249.172.36991: UDP, length 48
  0x0000:  .... .... .... .... .... .... .... ....  E..L@...?..P.}.9
  0x0010:  .... .... .... .... .... .... 2402 03e7  .....{...8..$...
  0x0020:  0000 0044 0000 0017 c944 586a e85d 2bd7  ...D.....DXj.]+.
  0x0030:  9da3 dbc5 e85d 2c80 b9ab e514 e85d 2c80  .....],......],.
  0x0040:  beff 6d74 e85d 2c80 bf00 b637            ..mt.],....7
```

We will be building and reading only past `24 02` so I've masked everything else.

First thing we need to build is the flags. This will be static so we can hardcode it later on:

| bits  | Description                                           |
| ----- | ----------------------------------------------------- |
| `00`  | Let's set the leap indicator[^4] to unknown           |
| `100` | The second three bits represent the NTP Version 4[^5] |
| `100` | And let's set this to be a **server**[^6]             |

So this in binary is `00100100` which is `24` in hexadecimal.

Then:

- Stratum[^7] we set to be a secondary reference, so `02`
- Pooling[^8] we set to `03`
- We are very precise so we set this to `e7` (0.000000 seconds)[^9]
- Delay is on the Ubuntu NTP server set to 0.001038 seconds (`00 00 00 44`)[^10]
- Dispersion is 0.000351 seconds (`00 00 00 17`)[^11]

And now for the actually important fields:

| bytes                     | Value                                 | Description                                                            |
| ------------------------- | ------------------------------------- | ---------------------------------------------------------------------- |
| `C9 44 58 6A`             | `201.68.88.106`                       | Reference ID[^12], later in implementation we will always use this one |
| `E8 5D 2B D7 9D A3 DB C5` | `Jul 15, 2023 14:29:43.615781531 UTC` | Reference Timestamp[^13]                                               |
| `E8 5D 2C 80 B9 AB E5 14` | `Jul 15, 2023 14:32:32.725279157 UTC` | Origin Timestamp[^14]                                                  |
| `E8 5D 2C 80 BE FF 6D 74` | `Jul 15, 2023 14:32:32.746085015 UTC` | Receive Timestamp[^15]                                                 |
| `E8 5D 2C 80 BF 00 B6 37` | `Jul 15, 2023 14:32:32.746104610 UTC` | Transmit Timestamp[^16]                                                |

### Closing notes on the reverse engineering

You will notice that `ntpdate` makes a couple of requests (visible in the `pcap` file). It does that by issuing separate requests with a different `origin` timestamp, and measuring the difference between the response. Then it calculates the offset and uses that to set the time. You can see that in the output of the command as well:

```bash
$ sudo ntpdate -u ntp.ubuntu.com
15 Jul 16:31:21 ntpdate[2273]: adjust time server 185.125.190.58 offset +0.113190 sec
```

Keep that in mind later when we will be implementing the server.

## A simple UDP server in Elixir

Ok, so we established that we will need to listen and respond to UDP packets. If you look at the requests above you can see we will need also need to listen on port `123`[^17].

In Erlang there is a module `:gen_udp`[^17] that has everything we need. Here is a little crash course on how to use it.

### Crash course on `:gen_udp` module

There are really only three methods we need to know and understand: `gen_udp.open/2`[^18], `gen_udp.recv/2`[^19] and `:gen_udp.send/4`[^20]. We start the server with:

```elixir
{:ok, socket} = :gen_udp.open(port, [:binary, {:active, false}])
```

and we receive it and respond with:

```elixir
case :gen_udp.recv(socket, 0) do
  {:ok, {ip, port, data}} ->
    :gen_udp.send(socket, ip, port, "Hello, world!")

  {:ok, :udp_closed} ->
    # do something

  {:error, reason} ->
    # do something
end
```

### Simple server

Easiest way to do this is with a recursive loop:

```elixir
defmodule SimpleServer do
  def init(port) do
    {:ok, socket} = :gen_udp.open(port, [:binary, {:active, false}])

    loop(socket)
  end

  def loop(socket) do
    case :gen_udp.recv(socket, 0) do
      {:ok, :udp_closed} ->
        # do something

      {:error, reason} ->
        # do something

      {:ok, {ip, port, data}} ->
        :gen_udp.send(socket, ip, port, "Hello, world!")
    end
  end
end

SimpleServer.init(123)
```

So, calling `init/1` with a port number will start the UDP server and call the first iteration of the `loop` method. In the `loop/1` method we block on waiting for the request, and once we get it we call the `loop/1` again.

To me this looked a bit like `GenServer`[^21] so I propose we rewrite it as such.

### A UDP GenServer

The idea is quite simple, we will still call the `loop`, but now with `handle_continue/2` function in the GenServer.

This gives us an Application we can register later.

```elixir
defmodule UdpServer do
  use GenServer

  def init(_params) do
    {:ok, socket} = :gen_udp.open(123, [:binary, {:active, false}])

    {:ok, socket, {:continue, :loop}}
  end

  def handle_continue(:loop, socket) do
    case :gen_udp.recv(socket, 0) do
      {:ok, :udp_closed} ->
        # TODO: implement

      {:error, reason} ->
        # TODO: implement

      {:ok, {ip, port, data}} ->
        :gen_udp.send(socket, ip, port, "Hello, world!")
        {:noreply, socket, {:continue, :loop}}
    end
  end
end
```

And if you want to register this somewhere the only thing we want to implement is the `start_link/1`[^22] method for this module:

```elixir
def start_link(params) do
  GenServer.start_link(__MODULE__, params, name: __MODULE__)
end
```

Now in your `application.ex` you can register it:

```elixir
defmodule Application do
  use Application

  def start(_type, _args) do
    children = [
      UdpServer
    ]

    opts = [strategy: :one_for_one, name: NtpServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
```

Cool! If you start this (if you don't know how look at the [Appendix A of this post](#appendix-a---creating-and-setting-up-a-basic-elixir-app-with-mix)) you can test it out.

## Building the NTP response in Elixir

In our GenServer we can add a new method: `generate_ntp_response` that will take the `request`, parse it, and return a new response.

So let's define it, and pattern match on the `request` right away:

```elixir
def generate_ntp_response(<<_::binary-size(40), origin_timestamp::binary>> = _request) do
end
```

Next up we need the current time, which we can get with: `System.system_time/1`[^23]:

```elixir
now = System.system_time(:second)
```

and using that we can set up our `receive` and `transmit` timestamps:

```elixir
receive_timestamp = now
transmit_timestamp = receive_timestamp
```

Next up is building our bitstring that will hold our response. I use a custom sigil `~b` so it's a bit easier to write out the hex numbers (check out [Appendix B](#appendix-b---our-custom-bitstring-sigil) for the implementation and the alternative).

### Header

Our header will contain a couple of things:

- our flags `24`
- stratum `02`
- pooling `03`
- precision `E7`
- two `32` bit blocks of `00` for delay and dispersion
- and our ID, e.g. `56 17 C3 1E`

So putting this together:

```elixir
header = ~b(23 02 03 E7) <> <<0::size(64)>>
id = ~b(56 17 C3 1E)
```

### Timestamps

Next up we need four timestamps. The value `2_208_988_800` represents the number of seconds between January 1, 1900, and January 1, 1970. This specific value is significant in the context of the Network Time Protocol (NTP) because NTP uses a different epoch than Unix-based systems[^24].

Unix-based systems, including Linux and macOS, use January 1, 1970, as the epoch (starting point) for representing time. However, NTP uses January 1, 1900, as its epoch.

To convert NTP timestamps to Unix timestamps (or vice versa), the offset of `2_208_988_800` is added or subtracted, depending on the direction of the conversion. Adding this offset ensures that the timestamps are properly aligned between the two systems.

For example, to convert an NTP timestamp to a Unix timestamp, you would add `2_208_988_800` to the NTP timestamp. This adjustment aligns the NTP time with Unix time, allowing for accurate comparisons and synchronization between NTP-based systems and Unix-based systems.

It's worth noting that the `2_208_988_800` offset is specific to NTP and the difference between the NTP epoch and Unix epoch. Other protocols or systems may use different epoch values and require different offsets for proper conversion between their timestamps and Unix timestamps.

All of our timestamps are seconds precision so we need to pad them a bit with `32` bits of `0`.

```elixir
reference_timestamp = <<receive_timestamp + @ntp_constant::size(32), 0::size(32)>>
origin_timestamp = origin_timestamp
receive_timestamp = <<receive_timestamp + @ntp_constant::size(32), 0::size(32)>>
transmit_timestamp = <<transmit_timestamp + @ntp_constant::size(32), 0::size(32)>>
```

Note that `origin` we just pass along.

### Putting it all together

All of the above would look something like this in our code:

```elixir
@ntp_constant 2_208_988_800

def generate_ntp_response(<<_::binary-size(40), origin_timestamp::binary>> = _request) do
  now = System.system_time(:second)

  receive_timestamp = now
  transmit_timestamp = receive_timestamp

  header = ~b(24 02 03 E7) <> <<0::size(64)>>
  id = ~b(56 17 C3 1E)
  reference_timestamp = <<receive_timestamp + @ntp_constant::size(32), 0::size(32)>>
  origin_timestamp = origin_timestamp
  receive_timestamp = <<receive_timestamp + @ntp_constant::size(32), 0::size(32)>>
  transmit_timestamp = <<transmit_timestamp + @ntp_constant::size(32), 0::size(32)>>

  <<header::binary, id::binary, reference_timestamp::binary, origin_timestamp::binary,
    receive_timestamp::binary, transmit_timestamp::binary>>
end
```

which, in turn, makes our `handle_continue/2` function look like:

```elixir
def handle_continue(:loop, socket) do
  case :gen_udp.recv(socket, 0) do
    {:ok, :udp_closed} ->
      Logger.warning("UDP socket closed")

    {:error, reason} ->
      Logger.error("Error: #{reason}")

    {:ok, {ip, port, request}} ->
      packet = generate_ntp_response(request)
      :gen_udp.send(socket, ip, port, packet)
      {:noreply, socket, {:continue, :loop}}
  end
end
```

In the finished implementation I've added some logging as well.

## Trying it out

So we start our Elixir NTP server with:

```bash
$ iex -S mix
```

and we can get ready to set the time. First let's edit `/etc/hosts` file and set our Macs IP as some hostname:

```text
127.0.1.1 ubuntu
127.0.0.1 localhost
::1   localhost ip6-localhost ip6-loopback
ff02::1   ip6-allnodes
ff02::2   ip6-allrouters
198.19.249.3  time.0x7f.dev
```

and then you can run `$ sudo ntpdate -u time.0x7f.dev`.

For those following along don't even try to set time on your computer with `time.0x7f.dev`. I am not crazy enough to run anything like this on public internet!

## The end

With this nice little exercise we covered two very cool parts of Elixir which have confused me for a long time: **bitstrings** and **GenServers**. While this could have been solved without the use of those two concepts (see my DNS in JS post) this made it easier to read and understand.

I've also had fun implementing my own custom sigil, which I am not sure if I would recommend to do in production code since it looks very "built-in".

And in the end I ended up finally understanding `tcpdump` and how it can be used to inspect traffic. Take a look at Wireshark for easier to read preview of `pcap` files.

Oh, and just to mention this can't be used to fake uptime... Unfortunately for me, but probably for the best, `uptime` does not work by comparing time with the one got from NTP.

### Appendix A - Creating and setting up a basic Elixir app with `mix`

Take a look at the Github repo[^25] that follows this post to see the complete image, but here are the steps how you can set up yours. First up you need to create a new `mix` project with:

```bash
$ mix new ntp_server
```

Next up we need a `lib/application.ex` file that will host our `Application` for registering our `GenServer`:

```elixir
# lib/application.ex
defmodule NtpServer.Application do
  use Application

  def start(_type, _args) do
    children = [
      NtpServer.UdpServer
    ]

    opts = [strategy: :one_for_one, name: NtpServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
```

and last we need to modify the `mix.exs` file:

```elixir
# mix.exs
defmodule NtpServer.MixProject do
  use Mix.Project

  def project do
    [
      app: :ntp_server,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {NtpServer.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
```

to register our Application with: `mod: {NtpServer.Application, []}`.

Now you can start the app with `iex -S mix` and get the IEX and our app running for experimentation.

### Appendix B - Our custom bitstring sigil

I've taken the time to implement our custom sigil[^26] in this project `~b` so we can save some time when writing out lists of hex values.

```elixir
<<0x7F>>
# becomes
~b(7F)
```

This was very simple to do with a bit of scaffolding:

```elixir
# lib/bitstring_sigil.ex
defmodule NtpServer.BitstringSigil do
  def sigil_b(string, _opts) do
    # TODO: implementation
  end
end

# lib/ntp_server.ex
defmodule NtpServer.UdpServer do
  use GenServer
  import NtpServer.BitstringSigil
end
```

And now for the algorithm (I used `dbg/0` to explain everything):

```elixir
string #=> "e3 00 03 fa"
|> String.upcase() #=> "E3 00 03 FA"
|> String.split("\n") #=> ["E3 00 03 FA"]
|> Enum.map(&String.split(&1, " ")) #=> [["E3", "00", "03", "FA"]]
|> List.flatten() #=> ["E3", "00", "03", "FA"]
|> Enum.reject(&(&1 == "")) #=> ["E3", "00", "03", "FA"]
|> Enum.join() #=> "E30003FA"
|> Base.decode16!() #=> <<227, 0, 3, 250>>
```

### Appendix C - Sending UDP packets

For this we can use the `netcat` method:

```bash
$ nc -4u localhost 123
```

And what ever you send (end it with an Enter) you will get back `Hello, world!`.

> If you find any typos or errors, please get in [touch](mailto:andrei@0x7f.dev)! I tried my best editing this but the post turned out huge.

---

[^1]: <https://orbstack.dev/>
[^2]: <https://www.wireshark.org/>
[^3]: <https://datatracker.ietf.org/doc/html/rfc1035#section-4.1.2>
[^4]: <https://datatracker.ietf.org/doc/html/rfc5905#:~:text=as%20follows%3A%0A%0A%20%20%20LI-,Leap%20Indicator,-(leap)%3A%202%2Dbit>
[^5]: <https://datatracker.ietf.org/doc/html/rfc5905#section-7.3:~:text=Leap%20Indicator%0A%0A%20%20%20VN-,Version%20Number,-(version)%3A%203%2Dbit>
[^6]: <https://datatracker.ietf.org/doc/html/rfc5905#section-7.3:~:text=number%2C%20currently%204.-,Mode%20(mode),-%3A%203%2Dbit%20integer>
[^7]: <https://datatracker.ietf.org/doc/html/rfc5905#section-7.3:~:text=10%3A%20Association%20Modes-,Stratum%20(stratum),-%3A%208%2Dbit%20integer>
[^8]: <https://datatracker.ietf.org/doc/html/rfc5905#section-7.3:~:text=for%20an%20example).-,Poll,-%3A%208%2Dbit%20signed>
[^9]: <https://datatracker.ietf.org/doc/html/rfc5905#section-7.3:~:text=and%2010%2C%20respectively.-,Precision,-%3A%208%2Dbit%20signed>
[^10]: <https://datatracker.ietf.org/doc/html/rfc5905#section-7.3:~:text=Specification%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20June%202010-,Root%20Delay,-(rootdelay)%3A%20Total%20round>
[^11]: <https://datatracker.ietf.org/doc/html/rfc5905#section-7.3:~:text=NTP%20short%20format.-,Root%20Dispersion,-(rootdisp)%3A%20Total%20dispersion>
[^12]: <https://datatracker.ietf.org/doc/html/rfc5905#section-7.3:~:text=NTP%20short%20format.-,Reference%20ID,-(refid)%3A%2032%2Dbit>
[^13]: <https://datatracker.ietf.org/doc/html/rfc5905#section-7.3:~:text=not%20be%20detected.-,Reference%20Timestamp,-%3A%20Time%20when%20the>
[^14]: <https://datatracker.ietf.org/doc/html/rfc5905#section-7.3:~:text=NTP%20timestamp%20format.-,Origin%20Timestamp,-(org)%3A%20Time%20at>
[^15]: <https://datatracker.ietf.org/doc/html/rfc5905#section-7.3:~:text=NTP%20timestamp%20format.-,Receive%20Timestamp,-(rec)%3A%20Time%20at>
[^16]: <https://datatracker.ietf.org/doc/html/rfc5905#section-7.3:~:text=NTP%20timestamp%20format.-,Transmit%20Timestamp,-(xmt)%3A%20Time%20at>
[^17]: <https://datatracker.ietf.org/doc/html/rfc5905#section-16>
[^18]: <https://www.erlang.org/doc/man/gen_udp.html#open-2>
[^19]: <https://www.erlang.org/doc/man/gen_udp.html#recv-2>
[^20]: <https://www.erlang.org/doc/man/gen_udp.html#send-4>
[^21]: <https://hexdocs.pm/elixir/1.15.3/GenServer.html>
[^22]: <https://hexdocs.pm/elixir/1.15.3/DynamicSupervisor.html#start_link/1>
[^23]: <https://hexdocs.pm/elixir/1.15.3/System.html#system_time/1>
[^24]: <https://datatracker.ietf.org/doc/html/rfc5905#section-7.3:~:text=In%20the%20date%20and%20timestamp%20formats%2C%20the%20prime%20epoch%2C%20or%20base%20date%20of%0A%20%20%20era%200%2C%20is%200%20h%201%20January%201900%20UTC%2C%20when%20all%20bits%20are%20zero.>
[^25]: <https://github.com/andreicek/ntp_server>
[^26]: <https://elixir-lang.org/getting-started/sigils.html>
