defmodule Ebae.AccountsTest do
  use Ebae.DataCase

  alias Ebae.{Accounts, Accounts.User, Accounts.Guardian, Accounts.ErrorHandler}

  @user_attrs %{
    "username" => "username",
    "credential" => %{email: "email", password: "password"}
  }
  @invalid_attrs %{
    "username" => nil,
    "credential" => nil
  }

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@user_attrs)
    user
  end

  describe "users" do
    setup [:create_user]

    test "get_user!/1 returns the user with given id", %{user: user} do
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user", %{user: user} do
      assert user.username == "username"
      assert user.credential.email == "email"
      assert Argon2.verify_pass("password", user.credential.password)
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "delete_user/1 deletes the user", %{user: user} do
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset", %{user: user} do
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end

    test "authenticate_user/2 with valid username and password returns user" do
      assert {:ok, user} = Accounts.authenticate_user("username", "password")
      assert user.username == "username"
      assert Argon2.verify_pass("password", user.credential.password)
    end

    test "authenticate_user/2 with invalid username returns error invalid credentials" do
      assert {:error, :invalid_credentials} =
               Accounts.authenticate_user("invalid username", "password")
    end

    test "authenticate_user/2 with invalid password returns error invalid credentials" do
      assert {:error, :invalid_credentials} =
               Accounts.authenticate_user("username", "incorrect password")
    end
  end

  describe "guardian" do
    setup [:create_user]

    test "subject_for_token/2 returns the user id", %{user: user} do
      assert {:ok, to_string(user.id)} == Guardian.subject_for_token(user, %{})
    end

    test "resource_from_claims/1 returns the user", %{user: user} do
      assert {:ok, user} == Guardian.resource_from_claims(%{"sub" => to_string(user.id)})
    end
  end

  describe "error handler" do
    alias Phoenix.ConnTest

    test "auth_error/3 returns a 401 with the auth error type" do
      conn =
        ErrorHandler.auth_error(
          ConnTest.build_conn(),
          {:unauthenticated, "Invalid credential"},
          []
        )

      assert ConnTest.text_response(conn, 401) =~ to_string(:unauthenticated)
    end
  end

  defp create_user(_) do
    {:ok, user: fixture(:user)}
  end
end
