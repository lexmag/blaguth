defmodule Blaguth do
  alias Plug.Conn

  def init(opts) do
    {realm, opts} = Keyword.pop(opts, :realm, "Restricted Area")

    init(realm, opts)
  end

  defp init(realm, credentials: {username, password}) when is_binary(realm) do
    %{realm: realm, creds: username <> ":" <> password}
  end

  def call(conn, config) do
    get_auth_header(conn)
    |> decode_creds
    |> assert_creds(config)
  end

  defp get_auth_header(conn) do
    {conn, Conn.get_req_header(conn, "authorization")}
  end

  defp decode_creds({conn, ["Basic " <> encoded_creds | _]}) do
    case Base.decode64(encoded_creds) do
      {:ok, creds} -> {conn, creds}
      :error       -> {conn, nil}
    end
  end

  defp decode_creds({conn, _}), do: {conn, nil}

  defp assert_creds({conn, val}, %{creds: val}),
    do: conn

  defp assert_creds({conn, _}, %{realm: realm}),
    do: halt_with_login(conn, realm)

  defp halt_with_login(conn, realm) do
    Conn.put_resp_header(conn, "Www-Authenticate", "Basic realm=\"" <> realm <> "\"")
    |> Conn.send_resp(401, "HTTP Basic: Access denied.\n")
    |> Conn.halt
  end
end
