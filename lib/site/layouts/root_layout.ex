defmodule Site.RootLayout do
  use Site.Component
  use Tableau.Layout

  def template(assigns) do
    ~H"""
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title>
          <%= [@page[:title], "0x7f"]
          |> Enum.filter(& &1)
          |> Enum.intersperse("|")
          |> Enum.join(" ") %>
        </title>

        <link rel="shortcut icon" type="image/x-icon" href="/favicon.png" />
        <link rel="stylesheet" href="https://unpkg.com/normalize.css" />
        <link rel="stylesheet" href="https://unpkg.com/magick.css" />
        <link rel="stylesheet" href="/css/app.css" />
      </head>
      <body>
        <%= @inner_content |> render() |> Phoenix.HTML.raw() %>
      </body>

      <%= if Mix.env() == :dev do %>
        <%= assigns |> Tableau.live_reload() |> Phoenix.HTML.raw() %>
      <% end %>
    </html>
    """
    |> Phoenix.HTML.Safe.to_iodata()
  end
end
