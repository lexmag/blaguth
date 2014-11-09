# Blaguth [![Build Status](https://travis-ci.org/lexmag/blaguth.svg)](https://travis-ci.org/lexmag/blaguth)

[Basic Access Authentication](http://tools.ietf.org/html/rfc2617) in Plug applications.

## Installation

Add Blaguth as a dependency to your `mix.exs` file:

```elixir
defp deps do
  [{:blaguth, "~> 1.0.0"}]
end
```

After you are done, run `mix deps.get` in your shell to fetch the dependencies.

## Usage

Add Blaguth on top of a Plug Stack as follows:

```elixir
defmodule CavePlug do
  import Plug.Conn
  use Plug.Builder

  plug Blaguth, realm: "Secret",
    credentials: {"Ali Baba", "Open Sesame"}

  plug :index

  def index(conn, _opts) do
    send_resp(conn, 200, "Hello Ali Baba")
  end
end
```

If you need more precise control over authentication process:

```elixir
defmodule AdvancedPlug do
  import Plug.Conn
  use Plug.Router

  plug Blaguth

  plug :match
  plug :dispatch

  get "/" do
    send_resp(conn, 200, "Everyone can see me!")
  end

  get "/secret" do
    if authenticated?(conn.assigns) do
      send_resp(conn, 200, "I'm only accessible if you know the password")
    else
      Blaguth.halt_with_login(conn, "Secret")
    end
  end

  defp authenticated?(%{credentials: {user, pass}}) do
    User.authenticate(user, pass)
  end
end
```

## License

This software is licensed under [the ISC license](LICENSE).
