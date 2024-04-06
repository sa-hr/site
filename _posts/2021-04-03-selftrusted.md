---
title: Generating a self-trusted certificate
date: 2021-04-03
---

<!--more-->

Enter the name of the domain here

<input id="domain" type="text" value="localhost.local" />

and run the following command

<pre id="command"></pre>

later on you can use those files with `serve` like this:

<code> npx serve --ssl-cert server.crt --ssl-key server.key</code>

<script>
  const domain = document.querySelector("#domain");
  const command = document.querySelector("#command");

  function gen(value = "localhost.local") {
    command.innerHTML = `openssl req -x509 -newkey rsa:4096 \\\n -sha256 -days 3650 -nodes \\\n -keyout server.key -out server.crt -subj '/CN=${value}' \\\n -extensions san \\
-config <(echo '[req]'; echo 'distinguished_name=req';
        echo '[san]'; echo 'subjectAltName=DNS:${value}')`;
  }

  domain.addEventListener("input", (e) => {
    const {
      target: { value },
    } = e;
    gen(value);
  });

  gen();
</script>
