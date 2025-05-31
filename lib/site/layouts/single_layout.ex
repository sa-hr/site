defmodule Site.SingleLayout do
  use Site.Component
  use Tableau.Layout, layout: Site.RootLayout

  def template(assigns) do
    ~H"""
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
    """
  end
end
