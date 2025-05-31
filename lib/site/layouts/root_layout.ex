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
        <.inner_content content={render(@inner_content)}/>

        <%= if Mix.env() == :dev do %>
          <%= assigns |> Tableau.live_reload() |> Phoenix.HTML.raw() %>
        <% end %>
        <script>
          document.addEventListener('DOMContentLoaded', function() {
            const glitchText = document.querySelector('.glitch-text');

            function triggerGlitch() {
              glitchText.classList.add('active');

              setTimeout(() => {
                glitchText.classList.remove('active');
              }, Math.random() * 200 + 100);

              setTimeout(triggerGlitch, Math.random() * 8000 + 2000);
            }

            setTimeout(triggerGlitch, Math.random() * 3000 + 1000);
          });
        </script>
      </body>

    </html>
    """
    |> Phoenix.HTML.Safe.to_iodata()
  end
end
