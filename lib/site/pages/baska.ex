defmodule Site.Baska do
  use Site.Component

  use Tableau.Page,
    layout: Site.RootLayout,
    permalink: "/visiting-baska"

  def template(assigns) do
    ~H"""
    <main>
      <header>
        <img src="/logo.svg" /> @ Baška, Krk
      </header>

      <h3>Parking</h3>

      <ul>
        <li>park <a href="https://maps.app.goo.gl/cGxQkcNssksGSmqn7">here</a> to unload car</li>
        <li>for paid parking go <a href="https://maps.app.goo.gl/R5jaE23ye5wJjFYA6">here</a> (15e a day?)</li>
        <li>for free when available go <a href="https://maps.app.goo.gl/uT49xQ9oiVDHv25s7">here</a></li>
      </ul>

      <figure>
        <img src="/baska/photo1.png" />
        <figcaption>From the "unloading" area to home</figcaption>
      </figure>

      <h3>Food</h3>
      <ul>
        <li>isolated but great food, very close to home <a href="https://maps.app.goo.gl/SGbMvquYnHAgVP1FA">maps</a> 8/10</li>
        <li>turisty, but ok food, larger prices but big portions; has kids menu <a href="https://maps.app.goo.gl/8hovsMHquTC499D59">maps</a></li>
        <li>tipical Adriatic place, but Croatian owner so I like this place <a href="https://maps.app.goo.gl/ZTQCe4vB7aRvzyj16">maps</a></li>
        <li>not the best pizza and beer, but cheap! <a href="https://maps.app.goo.gl/ykCAfZWZucLbzAh4A">maps</a></li>
        <li>good tuna burger; tuna, fruit skewers cool for the beach and kids <a href="https://maps.app.goo.gl/ASPMWrJENUySNFjT7">maps</a></li>
      </ul>

      <h3>Drinks</h3>
      <ul>
        <li>obvs, Malik, very good prices, great offering of beer, wine, and cocktails</li>
        <li>for spanish vibe, Petra loves it here <a href="https://maps.app.goo.gl/U4Ggh15HuhaTTW4t7">maps</a></li>
      </ul>

      <h3>Beach</h3>
      <ul>
        <li>either take a tax boat (around 100e) and go to wild beaches (you can hike, picku up your free hiking map near Forza restaurant in the Turist center</li>
        <li>or in front of the house, busy, but clean</li>
        <li>big turists ships, idk. good luck</li>
      </ul>
    </main>
    """
  end
end
