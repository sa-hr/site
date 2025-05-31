defmodule Site.HomePage do
  use Site.Component

  use Tableau.Page,
    layout: Site.RootLayout,
    permalink: "/"

  def template(assigns) do
    ~H"""
    <div class="home">
      <div>
        <h1 class="glitch-text" data-text="Andrei Crnkovic">Andrei Crnkovic</h1>
        <p>
          <a href="/posts">/posts</a>
        </p>
        <p>
          I am an open source advocate, licensed accountant, and elixir developer.
        </p>
        <p>
          Vice president at <a href="https://open.hr">HrOpen</a>
          • CEO at <a href="https://smartaccount.hr">SmartAccount</a>
          • Product engineer at <a href="https://contractbook.com">Contractbook</a>
        </p>
        <p>
          Feel free to email me at <a href="mailto:andrei@crnkovic.hr">andrei@crnkovic.hr</a>
        </p>
      </div>
    </div>
    """
  end
end
