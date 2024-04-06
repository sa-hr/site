defmodule Site.SingleLayout do
  use Site.Component
  use Tableau.Layout, layout: Site.RootLayout

  def template(assigns) do
    ~H"""
    <article>
      <header>
        <a href="/">&lt; Home of 0x7f.dev</a>

        <h1>
          <%= @page.title %>
        </h1>
        <%= if not is_nil(assigns[:date]) do %>
          <p>
            <%= Calendar.strftime(@page.date, "%Y-%m-%d") %>
          </p>
        <% end %>
      </header>

      <%= @inner_content |> render() |> Phoenix.HTML.raw() %>
    </article>
    """
    |> Phoenix.HTML.Safe.to_iodata()
  end
end
