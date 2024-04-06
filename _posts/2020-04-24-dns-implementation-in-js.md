---
title: DNS Implemenation in JS
date: 2020-04-24
---

When I first started with JavaScript I made my own DNS server in nodejs. This was a long time ago and unfortunately, that code is now lost (for better or for worse). I needed a few hours to wind down from work and I remembered having fun doing this all these years ago.

This blog post will explain, in detail, how I made my own DNS server in 2020.

## Requirements

You will need a few things. Some are optional, some are not:

- printout or PDF of the DNS specification (optional)
- a printout or PDF quick guide on DNS that I found online
- nodejs LTS installed (npm is optional)
- dig installed (dnsutils)
- a VM for testing (optional; I used the free one on Google Cloud)

## UDP and nodejs

The first thing I decided to tackle was UDP on nodejs. I’ve worked with TCP and HTTP a lot (I am a web developer after all) but never with UDP. So a quick google away I was able to make a quick UDP server using the built-in `dgram` library.

```javascript
const dgram = require("dgram");
const server = dgram.createSocket("udp4");

server.on("error", (e) => console.log("on error", e));
server.on("message", (d) => console.log("on message", d));
server.bind(5300);
```

This was enough to see something on my screen when I fired up dig with a request:

```
$ dig @127.0.0.1 -p 5300 andrei.fyi
```

The thing you will see displayed in your terminal will be something like this:

```
Buffer<1A A5 01 20...
```

My initial reaction was to just try and convert this to string `d.toString()` but I got garbage out with my domain visible. Success! At least for now. Without understanding the DNS protocol I couldn’t proceed.

### Optional: formating the buffer

This helped me a bunch! I found a nice lib `gagle/node-hex` that I used to format the buffers while I worked. If you pass in the same buffer in it: `console.log(hex(d));` you get something like this:

```
Offset 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F

000000 1A A5 01 20 00 01 00 00 00 00 00 01 06 61 6E 64 .¥. .........and
000010 72 65 69 03 66 79 69 00 00 01 00 01 00 00 29 10 rei.fyi.......).
000020 00 00 00 00 00 00 0C 00 0A 00 08 C3 59 36 ED 17 ...........ÃY6í.
000030 51 02 7E                                        Q.~
```

## Crash course in DNS

I recommend you read thru the documentation I linked. What we will need to understand before we start is how the DNS packet is constructed. In the formatted dump you can see hex sorted by two characters - this we call a byte! And two of them are called an octet. Let’s dissect the first part!

### 1. Header

```
000000   1A A5 01 20 00 01 00 00 00 00 00 01 06 61 6E 64   .¥. .........and
         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
```

I’ve underlined the first part we are going to parse. This we call the header of the request. It consits of multiple fields all 2 bytes long.

| Nam     | Value    |
| ------- | -------- |
| id      | 1A A5 \* |
| flags   | 01 20    |
| QDCOUNT | 00 01 \* |
| ANCOUNT | 00 00    |
| NSCOUNT | 00 00    |
| ARCOUNT | 00 01    |

Understanding this is not really needed but we need a few things from this table to move on. Those fields are marked with \*. id field is a uniq ID to the request and we need it so we can send it back in the response. The QDCOUNT fields is the number of questions we have. This tutorial and the server will only work by assuming you are asking it only one question.

### 2. Body

Next up is body. I’ve underlined it in the dump:

```
000000 1A A5 01 20 00 01 00 00 00 00 00 01 06 61 6E 64 .¥. .........and
                                           ~~~~~~~~~~~
000010 72 65 69 03 66 79 69 00 00 01 00 01 00 00 29 10 rei.fyi.......).
       ~~~~~~~~~~~~~~~~~~~~~~~
```

Now it’s important to understand how DNS sends ASCII text over the line. The format is really simple, and on our example, decoded, it looks like this:

| 06  | 61  | 6E  | 64  | 72  | 65  | 69  | 03  | 66  | 79  | 69  | 00  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 6   | a   | n   | d   | r   | e   | i   | 3   | f   | y   | i   | NC  |

From this we can observe that the body will end with a null char `00` (to here we parse the body) and every dot (.) is preceeded with how many letters are in front of it.

### 3. More flags

The last to octects are the TYPE and CLASS of our request. For all intensive purposes we are going to assume we are only interested in A records and IN class. Reade more about the available records here.

| Name  | Value |
| ----- | ----- |
| TYPE  | 00 01 |
| CLASS | 00 01 |

## Decoding and parsing the request

We already concluded that the data we get from the message event is a Buffer, but we have to parse it to understand it. My initial response to this was a toString but that didn’t work. But if we remember that we can convert hex numbers to decimal we can try converting this to a regular array!

```javascript
server.on("message", (msg, req) => {
  const packet = Array.from(msg);
});
```

And going from there we can just follow the table in headers. I used splice here because it’s a bit faster and easier than slice.

```javascript
const question = {
  id: packet.splice(0, 2),
  flags: packet.splice(0, 2),
  QDCOUNT: packet.splice(0, 2),
  ANCOUNT: packet.splice(0, 2),
  NSCOUNT: packet.splice(0, 2),
  ARCOUNT: packet.splice(0, 2),
};
```

We will only really use a few things from here but we stored it anyways for future :D. Next up is the body. If you go back and see that the actual body ends with 0x00 we can do something like this:

```javascript
packet.splice(0, packet.indexOf(0x00) + 1);
```

What we do here is look at what index is 0x00 and we include it as well (+1). What we still have to do is `TYPE` and `CLASS`. So our decoded question would look something like this:

```javascript
const question = {
  id: packet.splice(0, 2),
  flags: packet.splice(0, 2),
  QDCOUNT: packet.splice(0, 2),
  ANCOUNT: packet.splice(0, 2),
  NSCOUNT: packet.splice(0, 2),
  ARCOUNT: packet.splice(0, 2),
  body: packet.splice(0, packet.indexOf(0x00) + 1),
  TYPE: packet.splice(0, 2),
  CLASS: packet.splice(0, 2),
};
```

At this point all that is left we have to parse the body to a string.

## Parsing the body

Let’s look at the body again:

| 06  | 61  | 6E  | 64  | 72  | 65  | 69  | 03  | 66  | 79  | 69  | 00  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 6   | a   | n   | d   | r   | e   | i   | 3   | f   | y   | i   | NC  |

So the idea is to iterate thru that array and go forward the number of places we are told. So for the example the first iteration should be 6 chars forward, then we place a dot, and 3 chars forward.

```javascript
function parseBody(reqDomain) {
  const arr = Array.from(reqDomain);
  const domain = [];
  while (arr.length > 1) {
    const len = arr.shift();
    const section = arr.splice(0, len);
    domain.push(...section, 46);
  }

  domain.splice(-1, 1);

  return String.fromCharCode(...domain);
}
```

You might wonder why we have another `Array.from` there. Remember! that `splice` and `shift` are modifying the array so we make a copy. The `46` you can see at the push part is the ascii code for `.,` and that’s the dot in our domain name.

We have to splice once again to remove the trailing dot. Play around with this function so it makes sense. We can finally store the request domain name:

```javascript
const domain = parseBody(question.body);
```

## Encoding the response

Let’s start preparing the response. It’s very similar as the request, and we’ll include stuff from the request while constructing it. Take a moment and study this dump. See what’s the same and what’s different.

```
Offset 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F

000000 1A A5 81 80 00 01 00 01 00 00 00 00 06 61 6E 64 .¥...........and
000010 72 65 69 03 66 79 69 00 00 01 00 01 C0 0C 00 01 rei.fyi.....À...
000020 00 01 00 00 00 0A 00 04 68 F8 3C 2B             ........hø<+
```

| Name    | Value            |
| ------- | ---------------- |
| id      | question.id      |
| flags   | 81 80            |
| QDCOUNT | question.QDCOUNT |
| ANCOUNT | 00 01            |
| NSCOUNT | question.NSCOUNT |
| ARCOUNT | 00 00            |
| body    | question.body    |
| body    | question.TYPE    |
| body    | question.CLASS   |

We hardcoded the flags to make this a response, and we hardcoded the ANCOUNT. This is the number of answers we have. Other fields we copy over. And now the finale - we have to send out the IP!

I’ve created a simple json file with only one record:

```json
{
  "andrei.fyi": "104.248.60.43"
}
```

Parsing this to a an array of numbers is failry easy now:

```javascript
function stringIPToArray(ip) {
  if (!ip) {
    return [];
  }

  return ip.split(".").map((oct) => parseInt(oct, 10));
}
```

I’ve added a check here if there is no IP. This is to ensure that if we don’t know of an address we can respond with an empty field.

We also have a bunch of fields I decided to hardcode. If you want to know what they do read up; but I opted out on just following along the document linked above.

Let’s construct the response as a buffer:

```javascript
const response = Buffer.from([
  ...question.id,
  0x81,
  0x80,
  ...question.QDCOUNT,
  0x00,
  0x01,
  ...question.NSCOUNT,
  0x00,
  0x00,
  ...question.body,
  ...question.TYPE,
  ...question.CLASS,
  // the hardcoded flags
  0xc0,
  0x0c,
  0x00,
  0x01,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x0a,
  0x00,
  0x04,
  ...stringIPToArray(records[domain]),
]);
```

And that’s it! 🎉🎉 We can send it out.

## Sending the response

The second argument of the message event from above contains the request IP and port where we can send out the response.

```javascript
server.on("message", (msg, req) => {
  /* ... */
  server.send(response, 0, response.length, req.port, req.address);
});
```

And that’s it - now you have a working but a very basic DNS server.

## Example response

```
% dig @127.0.0.1 -p 5300 andrei.fyi

; <<>> DiG 9.11.5-P4-5.1ubuntu2.1-Ubuntu <<>> @127.0.0.1 -p 5300 andrei.fyi
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 52074
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 0

;; QUESTION SECTION:
;andrei.fyi.                    IN      A

;; ANSWER SECTION:
andrei.fyi.             10      IN      A       104.248.60.43

;; Query time: 1 msec
;; SERVER: 127.0.0.1#5300(127.0.0.1)
;; WHEN: Thu Apr 23 18:43:45 UTC 2020
;; MSG SIZE  rcvd: 44
```
