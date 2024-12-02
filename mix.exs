defmodule Annealing.MixProject do
  use Mix.Project

  def project do
    [
      app: :annealing,
      description: description(),
      package: package(),
      source_url: "https://github.com/typesend/annealing",
      homepage_url: "https://github.com/typesend/annealing",
      version: "0.5.0-beta.1",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description do
    "Annealing is a library for building and running simulated annealing algorithms in Elixir."
  end

  defp package do
    [
      maintainers: ["Ben Damman"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/typesend/annealing"}
    ]
  end

  defp deps do
    [
      {:typed_struct, "~> 0.3.0"},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.35.1", only: [:dev, :test], runtime: false}
    ]
  end
end
