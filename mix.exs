defmodule Exon.Mixfile do
  use Mix.Project

  def project do
    [app: :exon,
     version: "0.1.4",
     elixir: "~> 1.4",
     elixirc_paths: elixirc_paths(Mix.env),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     package: package(),
     docs: docs(),
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger],
     mod: {Exon.Application, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:ecto, "~> 2.1"},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:postgrex, ">= 0.13.2", only: :test},
    ]
  end

  defp description do
    """
    A collection of useful concepts for building DDD (Domain-Driven-Design) applications in Elixir
    """
  end

  defp package() do
    [
      maintainers: ["Neer Friedman"],
      licenses: ["MIT"],
      files: ~w(mix.exs README.md lib),
      links: %{"GitHub" => "https://github.com/neerfri/exon"}
    ]
  end

  defp docs() do
    [
      main: "readme",
      extras: ["README.md"],
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]
end
