defmodule Site.RootLayout do
  use Site.Component
  use Tableau.Layout

  def template(assigns) do
    css = "main.css"
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
        <nav>
          <h1><a href="/">Andrei's site</a></h1>
          <p>
            I am an open source advocate, licensed accountant, and elixir developer.
          </p>
          <ul>
            <li>
              Vice president at <a href="https://open.hr">HrOpen</a>
            </li>
            <li>
              CEO at <a href="https://smartaccount.hr">SmartAccount</a>
            </li>
            <li>
              Product engineer at <a href="https://contractbook.com">Contractbook</a>
            </li>
          </ul>
          <p>
            Feel free to email me at <a href="mailto:andrei@crnkovic.hr">andrei@crnkovic.hr</a>
          </p>
        </nav>
        <main>
          <.inner_content content={render(@inner_content)}/>
        </main>
      </body>

      <%= if Mix.env() == :dev do %>
        <%= assigns |> Tableau.live_reload() |> Phoenix.HTML.raw() %>
      <% end %>
    </html>
    """
    |> Phoenix.HTML.Safe.to_iodata()
  end
end
