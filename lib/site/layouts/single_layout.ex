defmodule Site.SingleLayout do
  use Site.Component
  use Tableau.Layout, layout: Site.RootLayout

  def template(assigns) do
    ~H"""
    <div class="single">
      <nav>

        <h1 class="glitch-text" data-text="Andrei's site">
          <a href="/posts">Andrei's site</a>
        </h1>

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
      <article>
        <header>
          <h1>
            <%= @page.title %>
          </h1>
          <%= if not is_nil(assigns[:date]) do %>
            <p>
              <%= Calendar.strftime(@page.date, "%Y-%m-%d") %>
            </p>
          <% end %>
        </header>

        <.inner_content content={render(@inner_content)}/>

      </article>
    </div>
    """
  end
end
