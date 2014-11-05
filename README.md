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
  use Plug.Router

  plug Blaguth, realm: "Secret",
    credentials: {"Ali Baba", "Open Sesame"}

  plug :match
  plug :dispatch

  get "/" do
    assign(conn, :logged_in, true)
    |> send_resp(200, "Hello Ali Baba")
  end
end
```

## License

This software is licensed under [the ISC license](LICENSE).
