defmodule EbaeWeb.BuyUITest do
  use EbaeWeb.ConnCase

  alias Ebae.{Accounts, Auctions}

  @auction_attrs %{
    name: "some auction",
    description: "some description",
    initial_price: 200.0
  }

  @bid_attrs %{
    offer: 205.0
  }

  @user_attrs %{
    username: "username",
    credential: %{email: "email", password: "password"}
  }
  @other_user_attrs %{
    username: "other username",
    credential: %{email: "other email", password: "password"}
  }

  def fixture(:user, attrs) do
    {:ok, user} = Accounts.create_user(attrs)
    user
  end

  describe "buy ui" do
    setup [:create_users]

    test "displays greeting", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)
      conn = get(conn, Routes.buy_path(conn, :index))
      assert html_response(conn, 200) =~ "Welcome buyer #{user.username}"
    end

    test "displays auctions for sale", %{conn: conn, user: user, other_user: other_user} do
      Auctions.create_auction(Map.put(@auction_attrs, :user_id, other_user.id))
      conn = Auth.sign_in(conn, user)
      conn = get(conn, Routes.buy_path(conn, :index))
      assert html_response(conn, 200) =~ "some auction"
      assert html_response(conn, 200) =~ "some description"
      assert html_response(conn, 200) =~ "200.0"
    end

    test "displays auctions with current bid", %{conn: conn, user: user, other_user: other_user} do
      {:ok, auction} = Auctions.create_auction(Map.put(@auction_attrs, :user_id, other_user.id))
      Auctions.create_bid(Map.merge(@bid_attrs, %{user_id: user.id, auction_id: auction.id}))
      conn = Auth.sign_in(conn, user)
      conn = get(conn, Routes.buy_path(conn, :index))
      assert html_response(conn, 200) =~ "some auction"
      assert html_response(conn, 200) =~ "some description"
      assert html_response(conn, 200) =~ "205.0"
    end

    test "displays link to item bid creation", %{conn: conn, user: user, other_user: other_user} do
      {:ok, auction} = Auctions.create_auction(Map.put(@auction_attrs, :user_id, other_user.id))
      conn = Auth.sign_in(conn, user)
      conn = get(conn, Routes.buy_path(conn, :index))
      assert html_response(conn, 200) =~ "href=\"/buy/#{auction.id}\""
    end

    test "displays link to buyers bids", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)
      conn = get(conn, Routes.buy_path(conn, :index))
      assert html_response(conn, 200) =~ "href=\"/buy/bids\""
    end

    test "displays buyers bids", %{conn: conn, user: user, other_user: other_user} do
      {:ok, auction} = Auctions.create_auction(Map.put(@auction_attrs, :user_id, other_user.id))
      {:ok, bid} = Auctions.create_bid(Map.merge(@bid_attrs, %{user_id: user.id, auction_id: auction.id}))
      conn = Auth.sign_in(conn, user)
      conn = get(conn, Routes.buy_path(conn, :bids))
      assert html_response(conn, 200) =~ "some auction"
      assert html_response(conn, 200) =~ "some description"
      assert html_response(conn, 200) =~ "205.0"
      assert html_response(conn, 200) =~ to_string(bid.inserted_at)
    end
  end

  defp create_users(_) do
    {:ok, user: fixture(:user, @user_attrs), other_user: fixture(:user, @other_user_attrs)}
  end
end
