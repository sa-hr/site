defmodule Site.Posts do
  use Site.Component

  use Tableau.Page,
    layout: Site.SingleLayout,
    title: "Posts",
    permalink: "/posts"

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
