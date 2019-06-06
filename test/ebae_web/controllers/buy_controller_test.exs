defmodule EbaeWeb.BuyControllerTest do
  use EbaeWeb.ConnCase

  alias Ebae.{Accounts, Auctions}

  @bid_attrs %{"offer" => "130.5"}
  @invalid_offer_attrs %{"offer" => "not a number"}
  @nil_bid_attrs %{"offer" => nil}

  defmodule MockDateTimePast do
    defdelegate compare(datetime1, datetime2), to: DateTime

    def utc_now do
      {:ok, now} = DateTime.from_naive(~N[2018-01-01 10:00:00], "Etc/UTC")
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

  describe "index" do
    setup [:create_users]

    test "renders buyer greeting page", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)
      conn = get(conn, Routes.buy_path(conn, :buy))
      assert html_response(conn, 200) =~ "Auctions for sale"
    end
  end

  describe "bids" do
    setup [:create_users]

    test "renders buyer bids page", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)
      conn = get(conn, Routes.buy_path(conn, :bids))
      assert html_response(conn, 200) =~ "Your bids"
    end
  end

  describe "won auctions" do
    setup [:create_users]

    test "renders buyer won auctions page", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)
      conn = get(conn, Routes.buy_path(conn, :won))
      assert html_response(conn, 200) =~ "Your won auctions"
    end
  end

  describe "new bid" do
    setup [:create_users]

    test "renders new bid form", %{conn: conn, user: user, other_user: other_user} do
      {:ok, auction} =
        Auctions.create_auction(
          Map.put(@auction_attrs, "user_id", other_user.id),
          MockDateTimePast
        )

      conn = Auth.sign_in(conn, user)
      conn = get(conn, Routes.buy_path(conn, :new, auction.id))
      assert html_response(conn, 200) =~ "New bid"
    end

    test "unauthenticated if unauthenticated", %{conn: conn, user: user} do
      {:ok, auction} =
        Auctions.create_auction(Map.put(@auction_attrs, "user_id", user.id), MockDateTimePast)

      conn = get(conn, Routes.buy_path(conn, :new, auction.id))
      assert text_response(conn, 401) =~ "unauthenticated"
    end
  end

  describe "create" do
    setup [:create_users]

    test "creates bid if data is valid", %{conn: conn, user: user, other_user: other_user} do
      {:ok, auction} =
        Auctions.create_auction(
          Map.put(@auction_attrs, "user_id", other_user.id),
          MockDateTimePast
        )

      conn = Auth.sign_in(conn, user)
      post(conn, Routes.buy_path(conn, :create, auction.id), bid: @bid_attrs)
      [bid] = Auctions.get_bids!(user)
      assert bid.offer == Decimal.from_float(130.5)
      assert bid.auction_id == auction.id
      assert bid.user_id == user.id
    end

    test "renders buyer index when data is valid", %{
      conn: conn,
      user: user,
      other_user: other_user
    } do
      {:ok, auction} =
        Auctions.create_auction(
          Map.put(@auction_attrs, "user_id", other_user.id),
          MockDateTimePast
        )

      conn = Auth.sign_in(conn, user)
      conn = post(conn, Routes.buy_path(conn, :create, auction.id), bid: @bid_attrs)
      assert get_flash(conn, :info) == "Bid successfully offered"
      assert redirected_to(conn) == Routes.buy_path(conn, :buy)
    end

    test "renders error when create auction fails", %{
      conn: conn,
      user: user,
      other_user: other_user
    } do
      {:ok, auction} =
        Auctions.create_auction(
          Map.put(@auction_attrs, "user_id", other_user.id),
          MockDateTimePast
        )

      conn = Auth.sign_in(conn, user)
      conn = post(conn, Routes.buy_path(conn, :create, auction.id), bid: @invalid_offer_attrs)
      assert get_flash(conn, :error) == "Form submission invalid"
      assert redirected_to(conn) == Routes.buy_path(conn, :new, auction.id)
    end

    test "renders error when data is missing", %{conn: conn, user: user, other_user: other_user} do
      {:ok, auction} =
        Auctions.create_auction(
          Map.put(@auction_attrs, "user_id", other_user.id),
          MockDateTimePast
        )

      conn = Auth.sign_in(conn, user)
      conn = post(conn, Routes.buy_path(conn, :create, auction.id), bid: @nil_bid_attrs)
      assert get_flash(conn, :error) == "All fields required"
      assert redirected_to(conn) == Routes.buy_path(conn, :new, auction.id)
    end
  end

  defp create_users(_) do
    {:ok, user: fixture(:user, @user_attrs), other_user: fixture(:user, @other_user_attrs)}
  end
end
