defmodule Site.RootLayout do
  use Site.Component
  use Tableau.Layout

  def template(assigns) do
    css = if assigns[:page][:style] == :new, do: "new.css", else: "main.css"
    assigns = Map.put(assigns, :css, css)

    ~H"""
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title>
          <%= [@page[:title], "Andrei Crnkovic"]
          |> Enum.filter(& &1)
          |> Enum.intersperse("|")
          |> Enum.join(" ") %>
        </title>

        <link rel="shortcut icon" type="image/x-icon" href="/favicon.png" />
        <link rel="stylesheet" href="https://unpkg.com/normalize.css" />
        <link
          href="https://fonts.googleapis.com/css2?family=Antic+Didone&family=Open+Sans:ital,wght@0,300..800;1,300..800&family=Tenor+Sans&display=swap"
          rel="stylesheet"
        />
        <link rel="stylesheet" href={"/css/#{@css}"} />
      </head>
      <body>
        <.inner_content content={render(@inner_content)}/>
      </body>

      <%= if Mix.env() == :dev do %>
        <%= assigns |> Tableau.live_reload() |> Phoenix.HTML.raw() %>
      <% end %>
    </html>
    """
    |> Phoenix.HTML.Safe.to_iodata()
  end
end
