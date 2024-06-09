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
        <link rel="stylesheet" href="/css/app.css" />
      </head>
      <body>
        <.inner_content content={render(@inner_content)}/>

        <footer>
          <p xmlns:cc="http://creativecommons.org/ns#">
            This work is licensed under
            <a
              href="https://creativecommons.org/licenses/by-sa/4.0/?ref=chooser-v1"
              target="_blank"
              rel="license noopener noreferrer"
              style="display:inline-block;">
                CC BY-SA 4.0
            </a>
            <img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/cc.svg?ref=chooser-v1" alt="">
            <img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/by.svg?ref=chooser-v1" alt="">
            <img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/sa.svg?ref=chooser-v1" alt="">
          </p>
        </footer>
      </body>

      <%= if Mix.env() == :dev do %>
        <%= assigns |> Tableau.live_reload() |> Phoenix.HTML.raw() %>
      <% end %>
    </html>
    """
    |> Phoenix.HTML.Safe.to_iodata()
  end
end
