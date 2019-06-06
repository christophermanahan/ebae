defmodule EbaeWeb.SellViewTest do
  use EbaeWeb.ConnCase, async: true

  alias Ebae.{Accounts, Auctions}
  alias EbaeWeb.SellView

  defmodule MockDateTimePast do
    defdelegate compare(datetime1, datetime2), to: DateTime

    def utc_now do
      {:ok, now} = DateTime.from_naive(~N[2018-01-01 10:00:00], "Etc/UTC")
      now
    end
  end

  defmodule MockDateTimePresent do
    defdelegate compare(datetime1, datetime2), to: DateTime

    def utc_now do
      {:ok, now} = DateTime.from_naive(~N[2019-01-01 11:00:00], "Etc/UTC")
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
  @other_user_attrs %{
    "username" => "other username",
    "credential" => %{email: "other email", password: "password"}
  }

  @bid_attrs %{
    "offer" => "130.5"
  }

  def fixture(:user, attrs) do
    {:ok, user} = Accounts.create_user(attrs)
    user
  end

  describe "username" do
    setup [:create_users]

    test "returns the current user", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)
      assert SellView.username(conn) == user.username
    end
  end

  describe "sold" do
    setup [:create_users]

    test "returns the sellers sold auctions", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)

      conn =
        post(conn, Routes.sell_path(conn, :create),
          auction: @auction_attrs,
          datetime: MockDateTimePast
        )

      auctions = Auctions.get_sellers_auctions!(user)
      assert SellView.sold(conn, MockDateTimeFuture) == auctions
    end
  end

  describe "auctions" do
    setup [:create_users]

    test "returns the current user's auctions", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)
      conn = post(conn, Routes.sell_path(conn, :create), auction: @auction_attrs)
      auctions = Auctions.get_sellers_auctions!(user)
      assert SellView.auctions(conn) == auctions
    end
  end

  describe "current_price" do
    setup [:create_users]

    test "returns the highest bid", %{conn: conn, user: user, other_user: other_user} do
      conn = Auth.sign_in(conn, user)

      post(conn, Routes.sell_path(conn, :create),
        auction: @auction_attrs,
        datetime: MockDateTimePast
      )

      [auction] = Auctions.get_sellers_auctions!(user, MockDateTimePresent)

      Auctions.create_bid(
        Map.merge(@bid_attrs, %{"user_id" => other_user.id, "auction_id" => auction.id})
      )

      assert SellView.current_price(Auctions.get_auction!(auction.id)) ==
               Decimal.from_float(130.5)
    end

    test "returns the initial price if there are no bids", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)

      post(conn, Routes.sell_path(conn, :create),
        auction: @auction_attrs,
        datetime: MockDateTimePast
      )

      [auction] = Auctions.get_sellers_auctions!(user, MockDateTimePresent)

      assert SellView.current_price(Auctions.get_auction!(auction.id)) ==
               Decimal.from_float(120.5)
    end
  end

  defp create_users(_) do
    {:ok, user: fixture(:user, @user_attrs), other_user: fixture(:user, @other_user_attrs)}
  end
end
