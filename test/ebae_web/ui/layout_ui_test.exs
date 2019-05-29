defmodule EbaeWeb.LayoutUI do
  use EbaeWeb.ConnCase

  alias Ebae.Accounts

  @user_attrs %{
    username: "username",
    credential: %{email: "email", password: "password"}
  }

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@user_attrs)
    user
  end

  describe "layout ui" do
    setup [:create_user]

    test "displays sign in if user is not signed in", %{conn: conn} do
      conn = get(conn, Routes.page_path(conn, :index))
      assert html_response(conn, 200) =~ "Sign in"
    end

    test "displays register if user is not signed in", %{conn: conn} do
      conn = get(conn, Routes.page_path(conn, :index))
      assert html_response(conn, 200) =~ "Register"
    end

    test "does not display sign out if user is not signed in", %{conn: conn} do
      conn = get(conn, Routes.page_path(conn, :index))
      refute html_response(conn, 200) =~ "Sign out"
    end

    test "displays sign out if user is signed in", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)
      conn = get(conn, Routes.page_path(conn, :index))
      assert html_response(conn, 200) =~ "Sign out"
    end

    test "does not display sign in if user is signed in", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)
      conn = get(conn, Routes.page_path(conn, :index))
      refute html_response(conn, 200) =~ "Sign in"
    end

    test "does not display register if user is signed in", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)
      conn = get(conn, Routes.page_path(conn, :index))
      refute html_response(conn, 200) =~ "Sign register"
    end
  end

  defp create_user(_) do
    {:ok, user: fixture(:user)}
  end
end
