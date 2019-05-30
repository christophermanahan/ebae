defmodule EbaeWeb.SellViewTest do
  use EbaeWeb.ConnCase, async: true

  alias Ebae.{Accounts, Auction}
  alias EbaeWeb.SellView

  @item_attrs %{
    available: true,
    description: "some description",
    initial_price: "120.5",
    name: "some name"
  }

  @user_attrs %{
    username: "username",
    credential: %{email: "email", password: "password"}
  }

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@user_attrs)
    user
  end

  describe "username" do
    setup [:create_user]

    test "returns the current user", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)
      assert SellView.username(conn) == user.username
    end
  end

  describe "items" do
    setup [:create_user]

    test "returns the current user's items", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)
      conn = post(conn, Routes.sell_path(conn, :create), item: @item_attrs)
      items = Auction.get_items!(user)
      assert SellView.items(conn) == items
    end
  end

  defp create_user(_) do
    {:ok, user: fixture(:user)}
  end
end
