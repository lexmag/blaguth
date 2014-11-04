defmodule BlaguthTest do
  use ExUnit.Case, async: true
  use Plug.Test

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

  defp call(conn) do
    CavePlug.call(conn, [])
  end

  defp assert_unauthorized(conn) do
    assert conn.status == 401
    assert get_resp_header(conn, "Www-Authenticate") == ["Basic realm=\"Secret\""]
    refute conn.assigns[:logged_in]
  end

  test "request without credentials" do
    conn = call(conn(:get, "/"))

    assert_unauthorized conn
  end

  test "request with invalid credentials" do
    headers = [{"authorization", "Basic " <> Base.encode64("Thief:Open Sesame")}]

    conn = call(conn(:get, "/", [], headers: headers))

    assert_unauthorized conn
  end

  test "request with valid credentials" do
    headers = [{"authorization", "Basic " <> Base.encode64("Ali Baba:Open Sesame")}]

    conn = call(conn(:get, "/", [], headers: headers))

    assert conn.status == 200
    assert conn.resp_body == "Hello Ali Baba"
    assert conn.assigns[:logged_in]
  end

  test "request with malformed credentials" do
    headers = [{"authorization", "Basic Zm9)"}]

    conn = call(conn(:get, "/", [], headers: headers))

    assert_unauthorized conn
  end

  test "request with wrong scheme" do
    headers = [{"authorization", "Bearer " <> Base.encode64("Ali Baba:Open Sesame")}]

    conn = call(conn(:get, "/", [], headers: headers))

    assert_unauthorized conn
  end
end
