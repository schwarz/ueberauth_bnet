defmodule Ueberauth.Strategy.Bnet.OAuth do
  use OAuth2.Strategy

  # Public API

  def client(opts \\ []) do
    config = Application.get_env(:ueberauth, Ueberauth.Strategy.Bnet.OAuth)

    opts =
      [strategy: __MODULE__]
      |> Keyword.merge(config)
      |> Keyword.merge(opts)

    # US is the fallback region
    region = Keyword.get(opts, :region, "us")

    site = "https://#{get_host(region)}"
    opts =
      opts
      |> Keyword.put(:site, site)
      |> Keyword.put(:authorize_url, "#{site}/authorize")
      |> Keyword.put(:token_url, "#{site}/token")

    json_library = Ueberauth.json_library()

    OAuth2.Client.new(opts)
    |> OAuth2.Client.put_serializer("application/json", json_library)
  end

  def authorize_url!(params \\ []) do
    OAuth2.Client.authorize_url!(client(params), params)
  end

  def get_token!(params \\ [], headers \\ [], opts \\ []) do
    OAuth2.Client.get_token!(client(opts), params, headers, opts)
  end

  # Strategy Callbacks

  def authorize_url(client, params) do
    OAuth2.Strategy.AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_param(:client_secret, client.client_secret)
    |> put_header("accept", "application/json")
    |> OAuth2.Strategy.AuthCode.get_token(params, headers)
  end

  defp get_host("cn"), do: "oauth.battlenet.com.cn"

  defp get_host(region) when region in ["us", "eu", "apac"] do
    "oauth.battle.net"
  end

end
