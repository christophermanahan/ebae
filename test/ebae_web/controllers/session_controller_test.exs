defmodule EbaeWeb.SessionControllerTest do
  use EbaeWeb.ConnCase

  alias Ebae.Accounts

  @user_attrs %{
    "username" => "username",
    "credential" => %{email: "email", password: "password"}
  }
  @invalid_attrs %{
    "username" => "username",
    "credential" => %{email: "email", password: "incorrect password"}
  }

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@user_attrs)
    user
  end

  describe "new session" do
    setup [:create_user]

    test "renders signin form", %{conn: conn} do
      conn = get(conn, Routes.session_path(conn, :new))
      assert html_response(conn, 200) =~ "Sign in"
    end

    test "redirects to index when user is signed in", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)
      conn = get(conn, Routes.session_path(conn, :new))
      assert get_flash(conn, :info) == "Already signed in"
      assert redirected_to(conn) == Routes.page_path(conn, :index)
    end
  end

  describe "create" do
    setup [:create_user]

    test "signs user in if data is valid", %{conn: conn} do
      conn = post(conn, Routes.session_path(conn, :create), user: @user_attrs)
      assert Auth.authenticated?(conn)
    end

    test "renders index when data is valid", %{conn: conn} do
      conn = post(conn, Routes.session_path(conn, :create), user: @user_attrs)
      assert get_flash(conn, :info) == "Welcome back"
      assert redirected_to(conn) == Routes.page_path(conn, :index)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.session_path(conn, :create), user: @invalid_attrs)
      assert get_flash(conn, :error) == "Invalid credentials"
      assert redirected_to(conn) == Routes.session_path(conn, :new)
    end
  end

  describe "delete" do
    setup [:create_user]

    test "signs user out", %{conn: conn} do
      conn = post(conn, Routes.session_path(conn, :create), user: @user_attrs)
      assert Auth.authenticated?(conn)
      conn = delete(conn, Routes.session_path(conn, :delete))
      refute Auth.authenticated?(conn)
    end

    test "renders signin form after signing out", %{conn: conn} do
      conn = post(conn, Routes.session_path(conn, :create), user: @user_attrs)
      conn = delete(conn, Routes.session_path(conn, :delete))
      assert get_flash(conn, :info) == "Farewell"
      assert redirected_to(conn) == Routes.session_path(conn, :new)
    end
  end

  defp create_user(_) do
    {:ok, user: fixture(:user)}
  end
end
