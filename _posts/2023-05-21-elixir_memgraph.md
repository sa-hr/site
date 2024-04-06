---
title: Experimenting with graph databases with Memgraph and Elixir
date: 2023-05-21
---

I had a conversation with Marko Budiselić [@mbudiselicbuda](https://twitter.com/mbudiselicbuda), the CTO at Memgraph[^1], during this year's DORS/CLUC conference[^2]. We discussed graph databases in detail and explored their capabilities and applications. Since I had no prior experience with graph databases, I found the discussion fascinating. As an enthusiastic user of Elixir, I was especially curious about the possibility of integrating Elixir with Memgraph and using its features within the Elixir ecosystem.

One of the biggest challenges when working with demos is obtaining actual data for the database. Fortunately, Memgraph offers fantastic "datasets"[^3] that you can use in their Memgraph Lab application. I've chosen to use the "Europe road network" model for this demo.

These datasets offered by Memgraph are specifically designed to showcase the power and versatility of their graph database solution. They are carefully curated collections of interconnected data, meticulously crafted to represent real-world scenarios and domains. By utilizing these datasets, we can get hands-on experience with Memgraph's features and functionalities.

The idea of this post is to experiment with Memgraph and see (1) if we can use it with Elixir at all, and (2) how it all works under the hood. As of the time of writing this I haven't found any tutorials or guides on how to use it with Elixir, and we obviously need to fix that ASAP 😀.

## Getting started

First we need to setup our demo environment. Here is a checklist of what we need before we start:

- [ ] Memgraph DB
- [ ] Membraph Lab (to set up the dataset)
- [ ] Livebook or Elixir IEx

Setting up Memgraph DB is super easy with a nice all in one package[^4]:

```shell
docker run -it \
  -p 127.0.0.1:7687:7687 \
  -p 127.0.0.1:7444:7444 \
  -p 127.0.0.1:3000:3000 \
  memgraph/memgraph-platform
```

With this you also get a Memgraph Lab application running on [http://localhost:3000](http://localhost:3000), or alternately you can use their Mac/Windows/Linux app[^5]. From there you can load your dataset.

[![Screen shot showing a Memgraph Lab application and a red arrow pointing to the check out existing datasets link](/memgraph/memgraph_1.png)](/memgraph/memgraph_1.png)

Select the "Europe road network dataset" from the list of all available datasets.

[![Screen shot showing a Memgraph Lab application and a red arrow pointing to the Europe road network dataset](/memgraph/memgraph_2.png)](/memgraph/memgraph_2.png)

## Setting up `bolt_sips`

We are going to use the Neo4j adapter library called `bolt_sips`[^6] to connect and query our database. The library readme contains some basic instructions but I'm going to sum up here what we need to do to get up and running as soon as possible. You'll need to add `{:bolt_sips, "~> 2.0"}` to your dependencies, or run this in your live environment `Mix.install([{:bolt_sips, "~> 2.0"}])`.

Next up is connecting:

```elixir
{:ok, _memgraph} = Bolt.Sips.start_link(url: "bolt://memgraph:memgraph@localhost:7687")
conn = Bolt.Sips.conn()
```

Note that here we use `memgraph:memgraph` auth, but you can specify anything you want here when running with `memgraph-platform`.

We can check if everything works OK by running:

```elixir
conn
|> Bolt.Sips.query!("return 1 as n")
|> Bolt.Sips.Response.first()
```

And if everything is OK we get `%{"n" => 1}`. Now we can start playing around.

## Planning our road trip

Let's say we want to travel from **Milan, Italy** to **Zagreb, Croatia**. Also, we want to rest every 150 km. Here is the query that we need:

```
MATCH path = (:City { name: "Milan" })
             -[:Road * bfs (e, v | e.length <= 150)]->
             (:City { name: "Zagreb" })
RETURN path;
```

You can run this by using `Bolt.Sips.query!` function. And as a result you will get results with all of the nodes in between. If we look at the `:records` we can find the nodes and the relationships we have. In this short demo we're going to only use the `:nodes` array:

```elixir
[
  %Bolt.Sips.Types.Node{id: 557, properties: %{"name" => "Milan"}, labels: ["City"]},
  %Bolt.Sips.Types.Node{id: 121, properties: %{"name" => "Bergamo"}, labels: ["City"]},
  %Bolt.Sips.Types.Node{id: 945, properties: %{"name" => "Verona"}, labels: ["City"]},
  %Bolt.Sips.Types.Node{id: 551, properties: %{"name" => "Mestre"}, labels: ["City"]},
  %Bolt.Sips.Types.Node{id: 922, properties: %{"name" => "Udine"}, labels: ["City"]},
  %Bolt.Sips.Types.Node{id: 906, properties: %{"name" => "Trieste"}, labels: ["City"]},
  %Bolt.Sips.Types.Node{id: 503, properties: %{"name" => "Ljubljana"}, labels: ["City"]},
  %Bolt.Sips.Types.Node{id: 1010, properties: %{"name" => "Zagreb"}, labels: ["City"]}
]
```

With a little mapping magic (available in the Livebook example) we can have our itinerary planned out:

```elixir
[
  {"Milan", "Bergamo"},
  {"Bergamo", "Verona"},
  {"Verona", "Mestre"},
  {"Mestre", "Udine"},
  {"Udine", "Trieste"},
  {"Trieste", "Ljubljana"},
  {"Ljubljana", "Zagreb"}
]
```

and mapped out using Mermaid graphs!

![Graph connecting nodes together, from Milan to Zagreb](/memgraph/graph.png)

The demo I shared was a simple introduction to Memgraph and graph databases, providing a foundation for understanding their capabilities. However, I have exciting plans to expand my exploration by working with larger datasets to delve into more intriguing ideas. Although the demo was basic, it ignited my imagination regarding the potential of Memgraph and graph databases in solving various problems. One of the remarkable advantages of Memgraph and graph databases is their efficiency in managing extensive and interconnected datasets.

I've provided a Livebook demo for you to play around[^7].

## Edit

Thanks to Marko for providing me with the info that you can use what ever username and password combo you want in order to connect for development.

[^1]: https://memgraph.com/
[^2]: https://2023.dorscluc.org/
[^3]: https://memgraph.com/topics/explore-datasets
[^4]: https://memgraph.com/docs/memgraph/install-memgraph-on-macos-docker
[^5]: https://memgraph.com/download/#memgraph-lab
[^6]: https://github.com/florinpatrascu/bolt_sips
[^7]: https://git.0x7f.dev/andreicek/memgraph-elixir-livebook/src/branch/master/memgraph.livemd
