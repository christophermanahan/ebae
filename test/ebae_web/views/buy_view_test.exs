defmodule EbaeWeb.BuyViewTest do
  use EbaeWeb.ConnCase, async: true

  alias Ebae.{Accounts, Auction}
  alias EbaeWeb.BuyView

  @item_attrs %{
    available: true,
    description: "some description",
    initial_price: "120.50",
    name: "some name"
  }

  @user_attrs %{
    username: "username",
    credential: %{email: "email", password: "password"}
  }
  @other_user_attrs %{
    username: "other username",
    credential: %{email: "other email", password: "password"}
  }

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@user_attrs)
    user
  end

  describe "username" do
    setup [:create_user]

    test "returns the current user", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)
      assert BuyView.username(conn) == user.username
    end
  end

  describe "items" do
    setup [:create_user]

    test "returns the current items for sale", %{conn: conn, user: user} do
      {:ok, other_user} = Accounts.create_user(@other_user_attrs)
      Auction.create_item(Map.put(@item_attrs, :user_id, other_user.id))
      conn = Auth.sign_in(conn, user)
      items = Auction.get_buyers_items!(user)
      assert BuyView.items(conn) == items
    end
  end

  defp create_user(_) do
    {:ok, user: fixture(:user)}
  end
end
