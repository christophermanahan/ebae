defmodule EbaeWeb.BuyControllerTest do
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

  describe "index" do
    setup [:create_user]

    test "renders buyer greeting page", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)
      conn = get(conn, Routes.buy_path(conn, :index))
      assert html_response(conn, 200) =~ "Items for sale"
    end
  end

  defp create_user(_) do
    {:ok, user: fixture(:user)}
  end
end
