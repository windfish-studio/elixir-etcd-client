defmodule EtcdClient.MixProject do
  use Mix.Project

  def project do
    [
      app: :etcd_client,
      version: "0.1.0-alpha.2",
      elixir: "~> 1.8",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      package: package(),
      description: description(),
      deps: deps(),
      name: "EtcdClient",
      source_url: "https://github.com/windfish-studio/elixir-etcd-client",
      docs: [
        main: "EtcdClient"
      ]
    ]
  end


  def application do
    [
      extra_applications: [:logger],
      mod: {EtcdClient.Application, []}
    ]
  end


  defp deps do
    [
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:grpc, "~> 0.4.0-alpha.2"}
    ]
  end

  defp package() do
    [
      licenses: ["GPL 3.0"],
      links: %{"GitHub" => "https://github.com/windfish-studio/elixir-etcd-client"}
    ]
  end

  defp description() do
    "ETCD client with basic functionality for elixir"
  end
end
