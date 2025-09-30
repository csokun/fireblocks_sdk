defmodule FireblocksSdk.MixProject do
  use Mix.Project

  @version "0.1.3"
  @repo_url "https://github.com/csokun/fireblocks_sdk"

  def getVersion(), do: @version

  def project do
    [
      app: :fireblocks_sdk,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Hex
      package: package(),
      description: "Elixir Fireblocks REST API Client",

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
      {:finch, "~> 0.20"},
      {:joken, "~> 2.6"},
      {:nimble_options, "~> 1.1"},
      {:uuid, "~> 1.1"},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
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
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @repo_url,
      extras: [
        "README.md",
        "CHANGELOG.md"
      ],
      skip_undefined_reference_warnings_on: ["CHANGELOG.md"]
    ]
  end
end
