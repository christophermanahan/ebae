defmodule EbaeWeb.RegistrationControllerTest do
  use EbaeWeb.ConnCase

  import Ecto.Query, warn: false

  alias Ebae.{Repo, Accounts, Accounts.User}

  @create_attrs %{
    username: "username",
    credential: %{email: "email", password: "password"}
  }
  @invalid_unique_username %{
    username: "username",
    credential: %{email: "another email", password: "password"}
  }
  @invalid_unique_email %{
    username: "another username",
    credential: %{email: "email", password: "password"}
  }
  @invalid_no_username %{
    username: nil,
    credential: %{email: "email", password: "password"}
  }
  @invalid_no_email %{
    username: "another username",
    credential: %{email: nil, password: "password"}
  }
  @invalid_no_password %{
    username: "another username",
    credential: %{email: "email", password: nil}
  }

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@create_attrs)
    user
  end

  describe "new user" do
    setup [:create_user]

    test "renders signup form", %{conn: conn} do
      conn = get(conn, Routes.registration_path(conn, :new))
      assert html_response(conn, 200) =~ "Sign up"
    end

    test "redirects to index when user is signed in", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)
      conn = get(conn, Routes.registration_path(conn, :new))
      assert get_flash(conn, :info) == "Already signed in"
      assert redirected_to(conn) == Routes.page_path(conn, :index)
    end
  end

  describe "create" do
    test "signs user up if data is valid", %{conn: conn} do
      post(conn, Routes.registration_path(conn, :create), user: @create_attrs)
      user = get_user("username")
      assert user.credential.email == "email"
      assert Argon2.verify_pass("password", user.credential.password)
    end

    test "signs user in if data is valid", %{conn: conn} do
      conn = post(conn, Routes.registration_path(conn, :create), user: @create_attrs)
      assert Auth.authenticated?(conn)
    end

    test "renders errors when username is not unique", %{conn: conn} do
      Accounts.create_user(@create_attrs)
      conn = post(conn, Routes.registration_path(conn, :create), user: @invalid_unique_username)
      assert get_flash(conn, :error) == "Username unavailable"
      assert redirected_to(conn) == Routes.registration_path(conn, :new)
    end

    test "renders errors when email is not unique", %{conn: conn} do
      Accounts.create_user(@create_attrs)
      conn = post(conn, Routes.registration_path(conn, :create), user: @invalid_unique_email)
      assert get_flash(conn, :error) == "Email unavailable"
      assert redirected_to(conn) == Routes.registration_path(conn, :new)
    end

    @tag :skip
    test "renders errors when username is not provided", %{conn: conn} do
      conn = post(conn, Routes.registration_path(conn, :create), user: @invalid_no_username)
      assert get_flash(conn, :error) == "All fields required"
      assert redirected_to(conn) == Routes.registration_path(conn, :new)
    end

    @tag :skip
    test "renders errors when email is not provided", %{conn: conn} do
      conn = post(conn, Routes.registration_path(conn, :create), user: @invalid_no_email)
      assert get_flash(conn, :error) == "All fields required"
      assert redirected_to(conn) == Routes.registration_path(conn, :new)
    end

    @tag :skip
    test "renders errors when password is not provided", %{conn: conn} do
      conn = post(conn, Routes.registration_path(conn, :create), user: @invalid_no_password)
      assert get_flash(conn, :error) == "All fields required"
      assert redirected_to(conn) == Routes.registration_path(conn, :new)
    end

    test "renders index after sign up completes", %{conn: conn} do
      conn = post(conn, Routes.registration_path(conn, :create), user: @create_attrs)
      assert get_flash(conn, :info) == "Welcome"
      assert redirected_to(conn) == Routes.page_path(conn, :index)
    end
  end

  defp create_user(_) do
    {:ok, user: fixture(:user)}
  end

  defp get_user(username) do
    Repo.one(from u in User, where: u.username == ^username)
    |> Repo.preload(:credential)
  end
end
