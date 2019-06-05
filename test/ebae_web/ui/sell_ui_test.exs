defmodule EbaeWeb.SellUITest do
  use EbaeWeb.ConnCase
  use Phoenix.HTML

  alias Ebae.{Accounts, Auctions}

  {:ok, start} = DateTime.from_naive(~N[2019-01-01 10:00:00], "Etc/UTC")
  {:ok, finish} = DateTime.from_naive(~N[2019-02-01 10:00:00], "Etc/UTC")

  @auction_attrs %{
    start: start,
    finish: finish,
    description: "some description",
    initial_price: "120.5",
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

  @bid_attrs %{offer: "120.5"}
  @higher_bid_attrs %{offer: "130.5"}

  def fixture(:user, attrs) do
    {:ok, user} = Accounts.create_user(attrs)
    user
  end

  def fixture(:bid, attrs, user_id, auction_id) do
    {:ok, bid} =
      Auctions.create_bid(Map.merge(attrs, %{user_id: user_id, auction_id: auction_id}))

    bid
  end

  describe "sell ui" do
    setup [:create_users]

    test "displays greeting", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)
      conn = get(conn, Routes.sell_path(conn, :sell))
      assert html_response(conn, 200) =~ "Welcome seller #{user.username}"
    end

    test "displays users current auctions", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)
      post(conn, Routes.sell_path(conn, :create), auction: @auction_attrs)
      conn = get(conn, Routes.sell_path(conn, :sell))
      assert html_response(conn, 200) =~ "some name"
      assert html_response(conn, 200) =~ "some description"
      assert html_response(conn, 200) =~ "120.5"
    end

    test "displays auction details page", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)
      post(conn, Routes.sell_path(conn, :create), auction: @auction_attrs)
      [auction] = Auctions.get_sellers_auctions!(user)
      conn = get(conn, Routes.sell_path(conn, :sell))
      assert html_response(conn, 200) =~ "href=\"/sell/#{auction.id}\">some name</a>"
    end

    test "displays auction bids", %{conn: conn, user: user, other_user: other_user} do
      conn = Auth.sign_in(conn, user)
      post(conn, Routes.sell_path(conn, :create), auction: @auction_attrs)
      [auction] = Auctions.get_sellers_auctions!(user)
      fixture(:bid, @bid_attrs, other_user.id, auction.id)
      fixture(:bid, @higher_bid_attrs, other_user.id, auction.id)
      conn = get(conn, Routes.sell_path(conn, :auction, auction.id))
      assert html_response(conn, 200) =~ "120.5"
      assert html_response(conn, 200) =~ "130.5"
    end

    test "displays create auction", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)
      conn = get(conn, Routes.sell_path(conn, :sell))
      assert html_response(conn, 200) =~ "href=\"/sell/new\""
    end

    test "displays delete auction", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)
      post(conn, Routes.sell_path(conn, :create), auction: @auction_attrs)
      [auction] = Auctions.get_sellers_auctions!(user)
      conn = get(conn, Routes.sell_path(conn, :sell))
      assert html_response(conn, 200) =~ "data-method=\"delete\" data-to=\"/sell/#{auction.id}\" href=\"/sell/#{auction.id}\""
    end
  end

  defp create_users(_) do
    {:ok, user: fixture(:user, @user_attrs), other_user: fixture(:user, @other_user_attrs)}
  end
end
