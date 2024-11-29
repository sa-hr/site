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

      <.inner_content content={render(@inner_content)}/>

    </article>
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
    """
  end
end
