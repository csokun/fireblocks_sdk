defmodule FireblocksSdk.MixProject do
  use Mix.Project

  @version "0.1.0"
  @repo_url "https://github.com/csokun/fireblocks_sdk"

  def project do
    [
      app: :fireblocks_sdk,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Hex
      package: package(),
      description: "Elixir Fireblocks REST Client",

      # Docs
      name: "FireblocksSdk",
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :crypto],
      mod: {FireblocksSdk.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:finch, "~> 0.14"},
      {:joken, "~> 2.5"},
      {:nimble_options, "~> 0.5"},
      {:uuid, "~> 1.1"},
      {:ex_doc, "~> 0.29", only: :dev, runtime: false},
      {:jason, "~> 1.4"}
    ]
  end

  defp package do
    [
      maintainers: ["Sokun Chorn"],
      licenses: ["MIT"],
      links: %{"GitHub" => @repo_url}
    ]
  end

  defp docs() do
    [
      main: "FireblocksSdk",
      source_ref: "v#{@version}",
      source_url: @repo_url
    ]
  end
end
