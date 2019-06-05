defmodule EbaeWeb.AuthTest do
  use EbaeWeb.ConnCase

  alias Ebae.{Accounts, Accounts.Guardian}

  @user_attrs %{
    "username" => "username",
    "credential" => %{email: "email", password: "password"}
  }

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@user_attrs)
    user
  end

  describe "current_user" do
    setup [:create_user]

    test "retrieves current user", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)
      assert Auth.current_user(conn) == user
    end
  end

  describe "sign in" do
    setup [:create_user]

    test "signs user in", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)
      assert Guardian.Plug.authenticated?(conn)
    end
  end

  describe "sign out" do
    setup [:create_user]

    test "signs user out", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)
      assert Guardian.Plug.authenticated?(conn)
      conn = Auth.sign_out(conn)
      refute Guardian.Plug.authenticated?(conn)
    end
  end

  describe "authenticated" do
    setup [:create_user]

    test "is true if user is signed in", %{conn: conn, user: user} do
      conn = Guardian.Plug.sign_in(conn, user)
      assert Auth.authenticated?(conn)
    end

    test "is false if user is not signed in", %{conn: conn, user: user} do
      conn = Guardian.Plug.sign_in(conn, user)
      assert Guardian.Plug.authenticated?(conn)
      conn = Guardian.Plug.sign_out(conn)
      refute Auth.authenticated?(conn)
    end
  end

  defp create_user(_) do
    {:ok, user: fixture(:user)}
  end
end
