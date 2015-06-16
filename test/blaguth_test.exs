defmodule BlaguthTest do
  use ExUnit.Case, async: true
  use Plug.Test

  defmodule CavePlug do
    import Plug.Conn
    use Plug.Builder

    plug Blaguth, realm: "Secret",
      credentials: {"Ali Baba", "Open Sesame"}

    plug :index

    defp index(conn, _opts) do
      assign(conn, :logged_in, true)
      |> send_resp(200, "Hello Ali Baba")
    end
  end

  defmodule PassthruPlug do
    import Plug.Conn
    use Plug.Builder

    plug Blaguth

    plug :authenticate
    plug :index

    defp authenticate(conn, _opts) do
      case conn.assigns[:credentials] do
        {"James", "837737"} -> conn
        _ -> Blaguth.halt_with_login(conn, "Top secret")
      end
    end

    defp index(conn, _opts) do
      assign(conn, :logged_in, true)
      |> send_resp(200, "Wellcome James")
    end
  end

  defp call(plug, headers) do
    conn(:get, "/", [], headers: headers)
    |> plug.call([])
  end

  defp assert_unauthorized(conn, realm) do
    assert conn.status == 401
    assert get_resp_header(conn, "www-authenticate") == ["Basic realm=\"" <> realm <> "\""]
    refute conn.assigns[:logged_in]
  end

  defp assert_authorized(conn, content) do
    assert conn.status == 200
    assert conn.resp_body == content
    assert conn.assigns[:logged_in]
  end

  defp auth_header(creds) do
    {"authorization", "Basic " <> Base.encode64(creds)}
  end

  test "request without credentials" do
    conn = call(CavePlug, [])

    assert_unauthorized conn, "Secret"
  end

  test "request with invalid credentials" do
    conn = call(CavePlug, [auth_header("Thief:Open Sesame")])

    assert_unauthorized conn, "Secret"
  end

  test "request with valid credentials" do
    conn = call(CavePlug, [auth_header("Ali Baba:Open Sesame")])

    assert_authorized conn, "Hello Ali Baba"
  end

  test "request with malformed credentials" do
    conn = call(CavePlug, [{"authorization", "Basic Zm9)"}])

    assert_unauthorized conn, "Secret"
  end

  test "request with wrong scheme" do
    conn = call(CavePlug, [
      {"authorization", "Bearer " <> Base.encode64("Ali Baba:Open Sesame")}
    ])

    assert_unauthorized conn, "Secret"
  end

  test "manual handling for invalid credentials" do
    conn = call(PassthruPlug, [auth_header("James")])

    assert_unauthorized conn, "Top secret"
  end

  test "manual handling for valid credentials" do
    conn = call(PassthruPlug, [auth_header("James:837737")])

    assert_authorized conn, "Wellcome James"
  end
end
