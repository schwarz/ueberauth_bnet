# Überauth Battle.net

> Battle.net OAuth2 strategy for Überauth.


## Installation

1. Setup your application on the [Battle.net Developer Portal](https://dev.battle.net).

1. Add `:ueberauth_bnet` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:ueberauth_bnet, "~> 0.3"}]
    end
    ```

1. Add the strategy to your applications:

    ```elixir
    def application do
      [applications: [:ueberauth_bnet]]
    end
    ```

1. Add Battle.net to your Überauth configuration:

    ```elixir
    config :ueberauth, Ueberauth,
      providers: [
        bnet: {Ueberauth.Strategy.Bnet, []}
      ]
    ```

1.  Update your provider configuration:

    ```elixir
    config :ueberauth, Ueberauth.Strategy.Bnet.OAuth,
      client_id: System.get_env("BNET_CLIENT_ID"),
      client_secret: System.get_env("BNET_CLIENT_SECRET"),
      region: System.get_env("BNET_REGION")
    ```

    By default the US region is used.

1.  Include the Überauth plug in your controller:

    ```elixir
    defmodule MyApp.AuthController do
      use MyApp.Web, :controller
      plug Ueberauth
      ...
    end
    ```

1.  Create the request and callback routes if you haven't already:

    ```elixir
    scope "/auth", MyApp do
      pipe_through :browser

      get "/:provider", AuthController, :request
      get "/:provider/callback", AuthController, :callback
    end
    ```

    Battle.net expects a HTTPS redirect URI, extra steps might be necessary to set it up for your dev environment.

1. Your controller needs to implement callbacks to deal with `Ueberauth.Auth` and `Ueberauth.Failure` responses.

For an example implementation see the [Überauth Example](https://github.com/ueberauth/ueberauth_example) application.

## Calling

Depending on the configured url you can initial the request through:

    /auth/bnet

Or with options:

    /auth/bnet?scope=wow.profile%20sc2.profile

By default the requested scope is `openid` and the region is US. Scope can be configured either explicitly as a `scope` query value on the request path or in your configuration:

```elixir
config :ueberauth, Ueberauth,
  providers: [
    bnet: {Ueberauth.Strategy.Bnet, [scope: "wow.profile sc2.profiles"]}
  ]
```

Available scopes are: `openid`, `d3.profile`, `wow.profile` and `sc2.profile`.

## License

Please see [LICENSE](https://github.com/schwarz/ueberauth_bnet/blob/master/LICENSE) for licensing details.
