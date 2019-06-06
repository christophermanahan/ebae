defmodule EbaeWeb.BuyUITest do
  use EbaeWeb.ConnCase

  alias Ebae.{Accounts, Auctions}

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
    "offer" => 205.0
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

  describe "buy ui" do
    setup [:create_users]

    test "displays greeting", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)
      conn = get(conn, Routes.buy_path(conn, :buy))
      assert html_response(conn, 200) =~ "Welcome buyer #{user.username}"
    end

    test "displays auctions for sale", %{conn: conn, user: user, other_user: other_user} do
      Auctions.create_auction(Map.put(@auction_attrs, "user_id", other_user.id), MockDateTimePast)
      conn = Auth.sign_in(conn, user)
      conn = get(conn, Routes.buy_path(conn, :buy), datetime: MockDateTimePresent)
      assert html_response(conn, 200) =~ "some name"
      assert html_response(conn, 200) =~ "some description"
      assert html_response(conn, 200) =~ "120.5"
    end

    test "displays auctions with current bid", %{conn: conn, user: user, other_user: other_user} do
      {:ok, auction} =
        Auctions.create_auction(
          Map.put(@auction_attrs, "user_id", other_user.id),
          MockDateTimePast
        )

      Auctions.create_bid(
        Map.merge(@bid_attrs, %{"user_id" => user.id, "auction_id" => auction.id})
      )

      conn = Auth.sign_in(conn, user)
      conn = get(conn, Routes.buy_path(conn, :buy), datetime: MockDateTimePresent)
      assert html_response(conn, 200) =~ "some name"
      assert html_response(conn, 200) =~ "some description"
      assert html_response(conn, 200) =~ "205.0"
    end

    test "displays link to item bid creation", %{conn: conn, user: user, other_user: other_user} do
      {:ok, auction} =
        Auctions.create_auction(
          Map.put(@auction_attrs, "user_id", other_user.id),
          MockDateTimePast
        )

      conn = Auth.sign_in(conn, user)
      conn = get(conn, Routes.buy_path(conn, :buy), datetime: MockDateTimePresent)
      assert html_response(conn, 200) =~ "href=\"/buy/#{auction.id}/new\""
    end

    test "displays link to buyers bids", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)
      conn = get(conn, Routes.buy_path(conn, :buy))
      assert html_response(conn, 200) =~ "href=\"/buy/bids\""
    end

    test "displays link to buyers won auctions", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)
      conn = get(conn, Routes.buy_path(conn, :buy))
      assert html_response(conn, 200) =~ "href=\"/buy/won\""
    end

    test "displays buyers bids", %{conn: conn, user: user, other_user: other_user} do
      {:ok, auction} =
        Auctions.create_auction(
          Map.put(@auction_attrs, "user_id", other_user.id),
          MockDateTimePast
        )

      {:ok, bid} =
        Auctions.create_bid(
          Map.merge(@bid_attrs, %{"user_id" => user.id, "auction_id" => auction.id})
        )

      conn = Auth.sign_in(conn, user)
      conn = get(conn, Routes.buy_path(conn, :bids))
      assert html_response(conn, 200) =~ "some name"
      assert html_response(conn, 200) =~ "some description"
      assert html_response(conn, 200) =~ "205.0"
      assert html_response(conn, 200) =~ to_string(bid.inserted_at)
    end

    test "displays won auctions", %{conn: conn, user: user, other_user: other_user} do
      {:ok, auction} =
        Auctions.create_auction(
          Map.put(@auction_attrs, "user_id", other_user.id),
          MockDateTimePast
        )

      Auctions.create_bid(
        Map.merge(@bid_attrs, %{"user_id" => user.id, "auction_id" => auction.id})
      )

      conn = Auth.sign_in(conn, user)
      conn = get(conn, Routes.buy_path(conn, :won), datetime: MockDateTimeFuture)
      assert html_response(conn, 200) =~ "some name"
      assert html_response(conn, 200) =~ "some description"
      assert html_response(conn, 200) =~ "205.0"
    end
  end

  defp create_users(_) do
    {:ok, user: fixture(:user, @user_attrs), other_user: fixture(:user, @other_user_attrs)}
  end
end
