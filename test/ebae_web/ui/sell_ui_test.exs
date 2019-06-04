defmodule EbaeWeb.SellUITest do
  use EbaeWeb.ConnCase

  alias Ebae.{Accounts, Auctions}

  @auction_attrs %{
    name: "some auction",
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

    test "displays users current auctions", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)
      post(conn, Routes.sell_path(conn, :create), auction: @auction_attrs)
      conn = get(conn, Routes.sell_path(conn, :index))
      assert html_response(conn, 200) =~ "some auction"
      assert html_response(conn, 200) =~ "some description"
      assert html_response(conn, 200) =~ "100.01"
    end

    test "displays create auction", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)
      conn = get(conn, Routes.sell_path(conn, :index))
      assert html_response(conn, 200) =~ "href=\"/sell/new\""
    end

    test "displays delete auction", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)
      post(conn, Routes.sell_path(conn, :create), auction: @auction_attrs)
      [auction] = Auctions.get_sellers_auctions!(user)
      conn = get(conn, Routes.sell_path(conn, :index))
      assert html_response(conn, 200) =~ "href=\"/sell/#{auction.id}\""
    end
  end

  defp create_user(_) do
    {:ok, user: fixture(:user)}
  end
end
