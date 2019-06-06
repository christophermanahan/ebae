defmodule EbaeWeb.BuyViewTest do
  use EbaeWeb.ConnCase, async: true

  alias Ebae.{Accounts, Auctions}
  alias EbaeWeb.BuyView

  defmodule MockDateTimePast do
    defdelegate compare(datetime1, datetime2), to: DateTime

    def utc_now do
      {:ok, now} = DateTime.from_naive(~N[2018-01-01 10:00:00], "Etc/UTC")
      now
    end
  end

  defmodule MockDateTimeFuture do
    defdelegate compare(datetime1, datetime2), to: DateTime

    def utc_now do
      {:ok, now} = DateTime.from_naive(~N[2020-01-01 10:00:00], "Etc/UTC")
      now
    end
  end

  {:ok, start} = DateTime.from_naive(~N[2019-01-01 10:00:00], "Etc/UTC")
  {:ok, finish} = DateTime.from_naive(~N[2019-02-01 10:00:00], "Etc/UTC")

  @auction_attrs %{
    "start" => start,
    "finish" => finish,
    "description" => "some description",
    "initial_price" => "120.5",
    "name" => "some name"
  }

  @bid_attrs %{
    "offer" => 130.5
  }

  @user_attrs %{
    "username" => "username",
    "credential" => %{email: "email", password: "password"}
  }
  @other_user_attrs %{
    "username" => "other username",
    "credential" => %{email: "other email", password: "password"}
  }

  def fixture(:user, attrs) do
    {:ok, user} = Accounts.create_user(attrs)
    user
  end

  describe "username" do
    setup [:create_users]

    test "returns the current user", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)
      assert BuyView.username(conn) == user.username
    end
  end

  describe "auctions" do
    setup [:create_users]

    test "returns the current auctions for sale", %{
      conn: conn,
      user: user,
      other_user: other_user
    } do
      Auctions.create_auction(Map.put(@auction_attrs, "user_id", other_user.id), MockDateTimePast)
      conn = Auth.sign_in(conn, user)
      auctions = Auctions.get_buyers_auctions!(user)
      assert BuyView.auctions(conn) == auctions
    end
  end

  describe "won" do
    setup [:create_users]

    test "returns the users won auctions", %{
      conn: conn,
      user: user,
      other_user: other_user
    } do
      {:ok, auction} = Auctions.create_auction(Map.put(@auction_attrs, "user_id", other_user.id), MockDateTimePast)

      Auctions.create_bid(
        Map.merge(@bid_attrs, %{"user_id" => user.id, "auction_id" => auction.id})
      )

      conn = Auth.sign_in(conn, user)
      auctions = Auctions.won!(user, MockDateTimeFuture)
      assert BuyView.won(conn, MockDateTimeFuture) == auctions
    end
  end

  describe "bids" do
    setup [:create_users]

    test "returns the users bids", %{
      conn: conn,
      user: user,
      other_user: other_user
    } do
      {:ok, auction} =
        Auctions.create_auction(Map.put(@auction_attrs, "user_id", other_user.id), MockDateTimePast)

      Auctions.create_bid(
        Map.merge(@bid_attrs, %{"user_id" => user.id, "auction_id" => auction.id})
      )

      conn = Auth.sign_in(conn, user)
      [bid] = BuyView.bids(conn)
      assert bid.offer == Decimal.from_float(130.5)
      assert bid.auction == auction
    end
  end

  describe "current_price" do
    setup [:create_users]

    test "returns the highest bid", %{user: user, other_user: other_user} do
      {:ok, auction} =
        Auctions.create_auction(Map.put(@auction_attrs, "user_id", other_user.id), MockDateTimePast)

      Auctions.create_bid(
        Map.merge(@bid_attrs, %{"user_id" => user.id, "auction_id" => auction.id})
      )

      assert BuyView.current_price(Auctions.get_auction!(auction.id)) == Decimal.from_float(130.5)
    end

    test "returns the initial price if there are no bids", %{user: user} do
      {:ok, auction} =
        Auctions.create_auction(Map.put(@auction_attrs, "user_id", user.id), MockDateTimePast)

      assert BuyView.current_price(Auctions.get_auction!(auction.id)) == Decimal.from_float(120.5)
    end
  end

  defp create_users(_) do
    {:ok, user: fixture(:user, @user_attrs), other_user: fixture(:user, @other_user_attrs)}
  end
end
