defmodule UeberauthBnet.Mixfile do
  use Mix.Project

  @version "0.3.0"

  def project() do
    [
      app: :ueberauth_bnet,
      version: @version,
      elixir: "~> 1.4",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: "Ueberauth strategy for Battle.net authentication.",
      package: package(),
      deps: deps(),
      name: "Ueberauth Battle.net",
      source_url: "https://github.com/schwarz/ueberauth_bnet"
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application() do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger]]
  end

  # Type "mix help deps" for more examples and options
  defp deps() do
    [
      {:oauth2, "~> 1.0 or ~> 2.0"},
      {:ueberauth, "~> 0.10"},
      {:ex_doc, "~> 0.31", only: [:dev], runtime: false}
    ]
  end

  defp package() do
    [
      name: :ueberauth_bnet,
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Bernhard Schwarz"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/schwarz/ueberauth_bnet"}
    ]
  end
end
