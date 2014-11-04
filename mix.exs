defmodule Blaguth.Mixfile do
  use Mix.Project

  def project do
    [app: :blaguth,
     version: "1.0.0",
     elixir: "~> 1.0",
     deps: deps,
     description: description,
     package: package]
  end

  def application do
    [applications: []]
  end

  defp deps do
    [{:cowboy, "~> 1.0", optional: true},
     {:plug, "~> 0.8.0"}]
  end

  defp description,
    do: "Basic Access Authentication in Plug applications."

  defp package do
    [contributors: ["Aleksei Magusev"],
     licenses: ["ISC"],
     links: %{"GitHub" => "https://github.com/lexmag/blaguth"}]
  end
end
