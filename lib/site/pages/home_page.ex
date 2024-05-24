defmodule Site.HomePage do
  use Site.Component

  use Tableau.Page,
    layout: Site.RootLayout,
    permalink: "/"

  def template(assigns) do
    ~H"""
    <main>
      <header>
        <img src="/logo.svg" />
      </header>

      <p>
        0x7f is an ASCII representation of the DEL charachter. Besides that it's a
        family run company that does Elixir product development and has launched
        a bookkeeping startup <a href="https://smartaccount.hr">SmartAccount</a>.
        On this site you can find an engineering blog and a personal site of Andrei.
      </p>

      <figure>
        <img src="/andrei_dors24.jpg" alt="Andrei at opening of DORS/CLUC 2024" />
        <figcaption>Andrei at opening of DORS/CLUC 2024</figcaption>
      </figure>

      <blockquote>
        Andrei has been a software developer for over a decade, boasting experience in
        both frontend and backend development. In recent years, he has shifted
        his focus to Elixir and Erlang, using these technologies to build his
        own accounting startup.
      </blockquote>

      <hr style="margin-top: 3rem;" />

      <h2>2024. speaking events</h2>

      <ul>
        <%= for talk <- Enum.reverse(@data["talks"]) do %>
          <li>
            <span><%= talk["date"] %></span>

            <%= if talk["link"] do %>
              <a href={talk["link"]}><%= talk["name"] %></a>
            <% else %>
              <%= talk["name"] %>
            <% end %>
          </li>
        <% end %>
      </ul>

      <hr style="margin-top: 3rem;" />

      <h2>Posts</h2>

      <ul>
        <%= for post <- Enum.take(@posts, 5) do %>
          <li>
            <span><%= Calendar.strftime(post.date, "%Y-%m-%d") %></span>
            <a href={post.permalink}><%= post.title %></a>
          </li>
        <% end %>
        <li>
        <a href="/posts">See more...</a>
        </li>
      </ul>

      <hr style="margin-top: 3rem;" />

      <h2>Links</h2>

      <ul>
        <%= for link <- @data["links"] do %>
          <li>
            <a href={link["href"]}><%= link["name"] %></a>
          </li>
        <% end %>
      </ul>

      <hr style="margin-top: 3rem;" />

      <h2>Member of</h2>
      <div style="text-align: center;">
        <a href="https://open.hr" style="text-decoration: none;">
          <img src="/hropen.png" style="width: 200px;" />
        </a>
        <a href="https://radiona.org" style="text-decoration: none;">
          <img src="/radiona.png" style="width: 200px; margin-left: 20px;" />
        </a>
        <a href="/posts/ripe-atlas-ambassador" style="text-decoration: none;">
          <img src="/ripe.png" style="width: 200px; margin-left: 20px;" />
        </a>
      </div>
    </main>
    """
  end
end
