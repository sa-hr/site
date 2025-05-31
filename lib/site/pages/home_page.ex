defmodule Site.HomePage do
  use Site.Component

  use Tableau.Page,
    layout: Site.RootLayout,
    permalink: "/",
    title: "Andrei"

  def template(assigns) do
    ~H"""
    <ul>
      <%= for post <- @posts do %>
        <li>
          <span><%= Calendar.strftime(post.date, "%Y-%m-%d") %></span>
          <a href={post.permalink}><%= post.title %></a>
        </li>
      <% end %>
    </ul>
    """
  end
end
