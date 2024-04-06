defmodule Site.MixProject do
  use Mix.Project

  def project do
    [
      app: :site,
      version: "0.0.1",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:telemetry, :logger]
    ]
  end

  defp deps do
    [
      {:tableau, "~> 0.16"},
      {:phoenix_live_view, "~> 0.20"}
    ]
  end
end
