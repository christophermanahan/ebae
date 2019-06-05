defmodule EbaeWeb.LayoutViewTest do
  use EbaeWeb.ConnCase, async: true

  alias Ebae.Accounts
  alias EbaeWeb.LayoutView

  @user_attrs %{
    "username" => "username",
    "credential" => %{email: "email", password: "password"}
  }

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@user_attrs)
    user
  end

  describe "authenticated" do
    setup [:create_user]

    test "returns true if the user is signed in", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)
      assert LayoutView.authenticated?(conn)
    end

    test "returns false if the user is not signed in", %{conn: conn} do
      refute LayoutView.authenticated?(conn)
    end
  end

  defp create_user(_) do
    {:ok, user: fixture(:user)}
  end
end
