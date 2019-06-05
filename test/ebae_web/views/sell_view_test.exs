defmodule EbaeWeb.SellViewTest do
  use EbaeWeb.ConnCase, async: true

  alias Ebae.{Accounts, Auctions}
  alias EbaeWeb.SellView

  @auction_attrs %{
    "start" => %{"day" => "1", "hour" => 10, "minute" => "0", "month" => "1", "year" => "2019"},
    "finish" => %{"day" => "1", "hour" => 10, "minute" => "0", "month" => "2", "year" => "2019"},
    "description" => "some description",
    "initial_price" => "120.5",
    "name" => "some name"
  }

  @user_attrs %{
    "username" => "username",
    "credential" => %{email: "email", password: "password"}
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

  describe "auctions" do
    setup [:create_user]

    test "returns the current user's auctions", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)
      conn = post(conn, Routes.sell_path(conn, :create), auction: @auction_attrs)
      auctions = Auctions.get_sellers_auctions!(user)
      assert SellView.auctions(conn) == auctions
    end
  end

  defp create_user(_) do
    {:ok, user: fixture(:user)}
  end
end
