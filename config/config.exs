import Config

config :tableau, :reloader,
  patterns: [
    ~r"lib/.*.ex",
    ~r"(_posts|_pages)/.*.md",
    ~r"(_data)/.*.(yaml|yml|exs)",
    ~r"assets/.*.(css|js)"
  ]

config :web_dev_utils, :reload_log, true
config :web_dev_utils, :reload_url, "'wss://' + location.host + '/ws'"

config :tableau, :config,
  url: "https://0x7f.dev",
  timezone: "Europe/Zagreb",
  markdown: [
    mdex: [
      extension: [table: true, header_ids: "", tasklist: true, strikethrough: true],
      render: [unsafe_: true],
      features: [syntax_highlight_theme: "solarized_light"]
    ]
  ]

config :tableau, Tableau.DataExtension, enabled: true
config :tableau, Tableau.SitemapExtension, enabled: true

config :tableau, Tableau.RSSExtension,
  enabled: true,
  title: "0x7f.dev",
  description: ""

config :tableau, Tableau.PostExtension,
  enabled: true,
  future: true,
  permalink: "/posts/:title",
  layout: "Site.SingleLayout"

config :tableau, Tableau.PageExtension,
  enabled: true,
  permalink: "/:title",
  layout: "Site.SingleLayout"

config :elixir, :time_zone_database, Tz.TimeZoneDatabase

import_config "#{Mix.env()}.exs"
