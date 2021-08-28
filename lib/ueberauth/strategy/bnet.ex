defmodule Ueberauth.Strategy.Bnet do
  use Ueberauth.Strategy, scope: "openid"

  # Callbacks
  @doc false
  def handle_request!(conn) do
    scopes = conn.params["scope"] || Keyword.get(default_options(), :scope)
    opts = [scope: scopes]

    opts =
      if conn.params["state"] do
        Keyword.put(opts, :state, conn.params["state"])
      else
        opts
      end

    opts =
      if conn.params["region"] do
        Keyword.put(opts, :region, conn.params["region"])
      else
        opts
      end

    opts = Keyword.put(opts, :redirect_uri, callback_url(conn))
    redirect!(conn, Ueberauth.Strategy.Bnet.OAuth.authorize_url!(opts))
  end

  @doc false
  def handle_callback!(%Plug.Conn{params: %{"code" => code}} = conn) do
    # opts = [redirect_uri: callback_url(conn)]
    region = get_region(code)

    client =
      Ueberauth.Strategy.Bnet.OAuth.get_token!(
        [code: code, redirect_uri: callback_url(conn)],
        [],
        region: region
      )

    if client.token.access_token == nil do
      err = client.token.other_params["error"]
      desc = client.token.other_params["error_description"]
      set_errors!(conn, [error(err, desc)])
    else
      conn
      |> store_token(client)
      |> fetch_user(client)
    end
  end

  @doc false
  def handle_callback!(conn) do
    set_errors!(conn, [error("missing_code", "No code received")])
  end

  @doc false
  def handle_cleanup!(conn) do
    conn
    |> put_private(:bnet_token, nil)
    |> put_private(:bnet_user, nil)
  end

  @doc false
  defp store_token(conn, client) do
    put_private(conn, :bnet_token, client.token)
  end

  @doc false
  defp fetch_user(conn, client) do
    resp = OAuth2.Client.get(client, "/oauth/userinfo")

    case resp do
      {:ok, %OAuth2.Response{status_code: 401, body: _body}} ->
        set_errors!(conn, [error("token", "unauthorized")])

      {:ok, %OAuth2.Response{status_code: status_code, body: user}}
      when status_code in 200..399 ->
        put_private(conn, :bnet_user, user)

      {:error, %OAuth2.Error{reason: reason}} ->
        set_errors!(conn, [error("OAuth2", reason)])
    end
  end

  @doc """
  Includes the credentials from the Battle.net response.
  """
  def credentials(conn) do
    token = conn.private.bnet_token

    scopes =
      (token.other_params["scope"] || "")
      |> String.split(" ")

    %Ueberauth.Auth.Credentials{
      expires: !!token.expires_at,
      expires_at: token.expires_at,
      scopes: scopes,
      refresh_token: token.refresh_token,
      token: token.access_token
    }
  end

  @doc """
  Fetches the uid field from the response.
  """
  def uid(conn) do
    Integer.to_string(conn.private.bnet_user["id"])
  end

  @doc """
  Fetches the fields to populate the info section of the `Ueberauth.Auth` struct.
  """
  def info(conn) do
    user = conn.private.bnet_user

    %Ueberauth.Auth.Info{
      nickname: user["battletag"]
    }
  end

  @doc """
  Stores the raw information (including the token and user) obtained from the Battle.net callback.
  """
  def extra(conn) do
    %Ueberauth.Auth.Extra{
      raw_info: %{
        token: conn.private.bnet_token,
        user: conn.private.bnet_user
      }
    }
  end

  defp get_region("EU" <> _code), do: "eu"
  defp get_region("KR" <> _code), do: "apac"
  defp get_region(_code), do: "us"
end
