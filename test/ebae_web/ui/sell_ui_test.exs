defmodule EbaeWeb.SellUITest do
  use EbaeWeb.ConnCase

  alias Ebae.Accounts

  @item_attrs %{
    name: "some item",
    description: "some description",
    initial_price: 100.01
  }

  @user_attrs %{
    username: "username",
    credential: %{email: "email", password: "password"}
  }

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@user_attrs)
    user
  end

  describe "sell ui" do
    setup [:create_user]

    test "displays greeting", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)
      conn = get(conn, Routes.sell_path(conn, :index))
      assert html_response(conn, 200) =~ "Welcome seller #{user.username}"
    end

    test "displays users current listings", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)
      post(conn, Routes.sell_path(conn, :create), item: @item_attrs)
      conn = get(conn, Routes.sell_path(conn, :index))
      assert html_response(conn, 200) =~ "some item"
    end
  end

  defp create_user(_) do
    {:ok, user: fixture(:user)}
  end
end
