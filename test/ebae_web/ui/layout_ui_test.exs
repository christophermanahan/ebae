defmodule EbaeWeb.LayoutUI do
  use EbaeWeb.ConnCase

  alias Ebae.{Accounts, Accounts.Guardian}

  @create_attrs %{
    username: "username",
    credential: %{email: "email", password: "password"}
  }

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@create_attrs)
    user
  end

  describe "layout ui" do
    setup [:create_user]

    test "displays sign in if user is not signed in", %{conn: conn} do
      conn = get(conn, "/")
      assert html_response(conn, 200) =~ "Sign in"
    end

    test "displays register if user is not signed in", %{conn: conn} do
      conn = get(conn, "/")
      assert html_response(conn, 200) =~ "Register"
    end

    test "does not display sign out if user is not signed in", %{conn: conn} do
      conn = get(conn, "/")
      refute html_response(conn, 200) =~ "Sign out"
    end

    test "displays sign out if user is signed in", %{conn: conn, user: user} do
      conn = Guardian.Plug.sign_in(conn, user)
      conn = get(conn, "/")
      assert html_response(conn, 200) =~ "Sign out"
    end

    test "does not display sign in if user is signed in", %{conn: conn, user: user} do
      conn = Guardian.Plug.sign_in(conn, user)
      conn = get(conn, "/")
      refute html_response(conn, 200) =~ "Sign in"
    end

    test "does not display register if user is signed in", %{conn: conn, user: user} do
      conn = Guardian.Plug.sign_in(conn, user)
      conn = get(conn, "/")
      refute html_response(conn, 200) =~ "Sign register"
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end
end
