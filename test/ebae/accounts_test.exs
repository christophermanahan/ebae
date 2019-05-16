defmodule Ebae.AccountsTest do
  use Ebae.DataCase

  alias Ebae.Accounts

  describe "users" do
    alias Ebae.Accounts.User
    alias Bcrypt

    @valid_attrs %{
      username: "some username",
      credential: %{email: "some email", password: "some password"}
    }
    @update_attrs %{
      username: "some updated username",
      credential: %{email: "some updated email", password: "some updated password"}
    }
    @invalid_attrs %{username: nil, credential: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.username == "some username"
      assert user.credential.email == "some email"
      assert Bcrypt.verify_pass("some password", user.credential.password)
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Accounts.update_user(user, @update_attrs)
      assert user.username == "some updated username"
      assert user.credential.email == "some updated email"
      assert Bcrypt.verify_pass("some updated password", user.credential.password)
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end

    test "authenticate_user/2 with valid username and password returns user" do
      user_fixture()
      assert {:ok, user} = Accounts.authenticate_user("some username", "some password")
      assert user.username == "some username"
    end

    test "authenticate_user/2 with invalid username and password returns error invalid credentials" do
      user_fixture()
      assert {:error, :invalid_credentials} = Accounts.authenticate_user("some username", "some incorrect password")
    end
  end

  describe "guardian" do
    alias Ebae.Accounts.Guardian

    test "subject_for_token/2 returns the user id" do
      user = user_fixture()
      assert {:ok, to_string(user.id)} == Guardian.subject_for_token(user, %{})
    end

    test "resource_from_claims/1 returns the user" do
      user = user_fixture()
      assert {:ok, user} == Guardian.resource_from_claims(%{:sub => user.id})
    end
  end
end
