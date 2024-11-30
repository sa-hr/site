defmodule Site.HomePage do
  use Site.Component

  use Tableau.Page,
    layout: Site.RootLayout,
    permalink: "/",
    style: :new

  def template(assigns) do
    ~H"""
    <main class="main">
      <div class="hero">
        <img class="me" src="/me.png" />
      </div>
      <h1>
        Andrei Crnkovic is the Founding Engineer at <em>Ploy</em>, Advisor at
        <em>SmartAccount</em>, and Vice President at <em>HrOpen</em>
      </h1>
      <div class="main__info">
        <p>
          With over 15 years of software development experience, Andrei brings a
          unique blend of technical expertise, financial acumen, and leadership
          to his roles. His mixed background as both a licensed accountant and
          seasoned developer allows him to bridge the gap between business needs
          and technical solutions.
        </p>
        <p>
          Currently shaping the future of access management at an early-stage
          startup, advising a boutique accounting firm, and championing open
          source initiatives, he combines strategic thinking with hands-on
          expertise to drive impactful results across technology and business
          domains.
        </p>
      </div>
      <div class="main__work">
        <div class="main__work-item">
          <div class="main__work-item-left">
            <h3>
              Founding Engineer at
              <a href="https://joinploy.com/" target="_blank">Ploy</a>
            </h3>
            <span>2024 — Current </span>
          </div>
          <div class="main__work-item-right">
            <p>
              I'm deeply involved in building and shaping our access management
              and shadow IT platform from the ground up. As the first
              engineering hire, I work in Elixir to develop core features while
              staying closely connected to our customers' needs. My role bridges
              technical development with practical value delivery - essential
              for our growing startup.
            </p>
            <p>
              Some of my key contributions include launching our AWS integration
              and creating an innovative graph visualization system that gives
              customers clear insights into their access patterns. I thrive on
              making complex access management more straightforward and
              actionable for our users, drawing on my full-stack expertise to
              build intuitive features.
            </p>
          </div>
        </div>
        <div class="main__work-item">
          <div class="main__work-item-left">
            <h3>
              Advisor at
              <a href="https://smartaccount.hr/" target="_blank">
                SmartAccount
              </a>
            </h3>
            <span>2021 — Current </span>
          </div>
          <div class="main__work-item-right">
            <p>
              As the founder, I started up a boutique accounting firm with a
              vision to make accounting more approachable for SMBs. Today, I
              serve in an advisory capacity, guiding strategic decisions and
              company direction while having previously developed our
              user-friendly application that simplifies accounting processes for
              end users.
            </p>
            <p>
              As a licensed accountant, I provide consulting to our accountants,
              helping them solve complex accounting challenges and devise
              innovative solutions for our clients. My current advisory focus
              ensures the company continues to evolve while maintaining its core
              mission of simplified, approachable accounting for growing
              businesses.
            </p>
          </div>
        </div>
        <div class="main__work-item">
          <div class="main__work-item-left">
            <h3>
              Vice President at
              <a href="https://hropen.hr/" target="_blank">HrOpen</a>
            </h3>
            <span>2022 — Current </span>
          </div>
          <div class="main__work-item-right">
            <p>
              I help lead an organisation dedicated to promoting open source
              projects and principles in Croatia. My commitment to open source
              extends through multiple channels: I contribute to Free Software
              Foundation Europe (FSFE) initiatives, including the translation of
              children's educational materials and advocating for the "Public
              Money Public Code" campaign in Croatia. As a grant committee
              member for the City of Zagreb, I help shape the future of
              technology initiatives in our community.
            </p>
            <p>
              One of my proudest contributions is my work with DORS/CLUC,
              Croatia's landmark open source conference celebrating over 30
              years of community impact, where I'm deeply involved in everything
              from curating talks to hands-on event management. This combination
              of roles allows me to bridge grassroots open source advocacy with
              institutional support, helping to build a stronger and more
              inclusive tech community.
            </p>
          </div>
        </div>
      </div>
      <div class="main__info">
        <p>
          If you or your organization is seeking guidance on innovative
          technical solutions, needs strategic advice on business growth, or
          would benefit from expertise spanning technology and finance, I'd be
          glad to help. Whether you're looking to discuss specific challenges,
          explore potential solutions, or simply connect for a conversation
          about technology, business, or open source - please get in touch. I'm
          always eager to share insights, learn from people, and collaborate on
          meaningful projects.
        </p>
      </div>
    </main>
    <footer class="footer">
      <div class="footer_links">
        <a href="https://github.com/andreicek" target="_blank">Github</a> /
        <a href="https://bsky.app/profile/andrei.crnkovic.hr" target="_blank">Bluesky</a>
        /
        <a href="https://www.linkedin.com/in/andreicek/" target="_blank">
          LinkedIn
        </a>
      </div>
      <div class="footer__logo">
        <img src="/crnkovic.png" />
        <a href="https://crnkovic.hr">Crnkovic Legacy Holdings</a>
      </div>
    </footer>
    """
  end
end
