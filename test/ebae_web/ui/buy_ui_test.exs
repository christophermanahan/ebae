defmodule EbaeWeb.BuyUITest do
  use EbaeWeb.ConnCase

  alias Ebae.{Accounts, Auction, Auction.Bid}

  @item_attrs %{
    name: "some item",
    description: "some description",
    initial_price: 100.01
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

  describe "sell ui" do
    setup [:create_user]

    test "displays greeting", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)
      conn = get(conn, Routes.buy_path(conn, :index))
      assert html_response(conn, 200) =~ "Welcome buyer #{user.username}"
    end

    test "displays items for sale", %{conn: conn, user: user} do
      {:ok, other_user} = Accounts.create_user(@other_user_attrs)
      Auction.create_item(Map.put(@item_attrs, :user_id, other_user.id))
      conn = Auth.sign_in(conn, user)
      conn = get(conn, Routes.buy_path(conn, :index))
      assert html_response(conn, 200) =~ "some item"
      assert html_response(conn, 200) =~ "some description"
      assert html_response(conn, 200) =~ "100.01"
    end
  end

  defp create_user(_) do
    {:ok, user: fixture(:user)}
  end
end
