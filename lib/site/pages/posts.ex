defmodule Site.Posts do
  use Site.Component

  use Tableau.Page,
    layout: Site.SingleLayout,
    title: "Posts",
    permalink: "/posts"

  def template(assigns) do
    ~H"""
    <p>
      Here you can find posts dating back to 2013, which is certanly not the first post I made,
      but a lot were lost in backups. There is also a gap of 6 years that's missing.
    </p>

    <ul>
      <%= for post <- @posts do %>
        <li>
          <span><%= Calendar.strftime(post.date, "%Y-%m-%d") %></span>
          <a href={post.permalink}><%= post.title %></a>
        </li>
      <% end %>
    </ul>
    """
    |> Phoenix.HTML.Safe.to_iodata()
  end
end
