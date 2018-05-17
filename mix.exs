defmodule Blaguth.Mixfile do
  use Mix.Project

  def project() do
    [
      app: :blaguth,
      version: "1.2.3",
      elixir: "~> 1.0",
      deps: deps(),
      description: description(),
      package: package(),
    ]
  end

  def application() do
    [applications: []]
  end

  defp deps() do
    [
      {:cowboy, "~> 1.0.1 or ~> 1.1 or ~> 2.1", optional: true},
      {:plug, ">= 1.0.0"},
    ]
  end

  defp description() do
    "Basic Access Authentication in Plug applications."
  end

  defp package() do
    [
      maintainers: ["Aleksei Magusev"],
      licenses: ["ISC"],
      links: %{"GitHub" => "https://github.com/lexmag/blaguth"},
    ]
  end
end
