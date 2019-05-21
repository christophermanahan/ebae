defmodule EbaeWeb.LayoutViewTest do
  use EbaeWeb.ConnCase, async: true

  alias Ebae.{Accounts, Accounts.Guardian}
  alias EbaeWeb.LayoutView

  @create_attrs %{
    username: "username",
    credential: %{email: "email", password: "password"}
  }

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@create_attrs)
    user
  end

  describe "signed in" do
    setup [:create_user]

    test "returns true if the user is signed in", %{conn: conn, user: user} do
      conn = Guardian.Plug.sign_in(conn, user)
      assert LayoutView.signed_in?(conn)
    end

    test "returns false if the user is not signed in", %{conn: conn} do
      refute LayoutView.signed_in?(conn)
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end
end
