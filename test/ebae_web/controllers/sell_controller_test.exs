defmodule EbaeWeb.SellControllerTest do
  use EbaeWeb.ConnCase
  use Phoenix.HTML

  alias Ebae.{Accounts, Auctions}

  defmodule MockDateTime do
    defdelegate compare(datetime1, datetime2), to: DateTime

    def utc_now do
      {:ok, now} = DateTime.from_naive(~N[2018-01-01 10:00:00], "Etc/UTC")
      now
    end
  end

  {:ok, start} = DateTime.from_naive(~N[2019-01-01 10:00:00], "Etc/UTC")
  {:ok, finish} = DateTime.from_naive(~N[2019-02-01 10:00:00], "Etc/UTC")
  @create_attrs %{
    "start" => start,
    "finish" => finish,
    "description" => "some description",
    "initial_price" => "120.5",
    "name" => "some name"
  }

  @auction_attrs %{
    "start" => %{"day" => "1", "hour" => 10, "minute" => "0", "month" => "1", "year" => "2019"},
    "finish" => %{"day" => "1", "hour" => 10, "minute" => "0", "month" => "2", "year" => "2019"},
    "description" => "some description",
    "initial_price" => "120.5",
    "name" => "some name"
  }
  @price_invalid_attrs %{
    "start" => %{"day" => "1", "hour" => 10, "minute" => "0", "month" => "1", "year" => "2019"},
    "finish" => %{"day" => "1", "hour" => 10, "minute" => "0", "month" => "2", "year" => "2019"},
    "description" => "some description",
    "initial_price" => "invalid string",
    "name" => "some name"
  }
  @nil_auction_attrs %{
    "description" => "",
    "initial_price" => "",
    "name" => "",
    "start" => nil,
    "finish" => nil
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

    test "renders seller greeting page", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)
      conn = get(conn, Routes.sell_path(conn, :sell))
      assert html_response(conn, 200) =~ "Your current auctions"
    end
  end

  describe "auction" do
    setup [:create_users]

    test "renders auction details page", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)
      post(conn, Routes.sell_path(conn, :create), auction: @auction_attrs, datetime: MockDateTime)
      [auction] = Auctions.get_sellers_auctions!(user)
      conn = get(conn, Routes.sell_path(conn, :auction, auction.id))
      assert html_response(conn, 200) =~ "Auction details"
    end

    test "renders error if auction does not belong to seller", %{
      conn: conn,
      user: user,
      other_user: other_user
    } do
      conn = Auth.sign_in(conn, user)

      {:ok, auction} =
        Auctions.create_auction(Map.put(@create_attrs, "user_id", other_user.id), MockDateTime)

      conn = get(conn, Routes.sell_path(conn, :auction, auction.id))
      assert get_flash(conn, :error) == "Invalid auction"
      assert redirected_to(conn) == Routes.sell_path(conn, :sell)
    end
  end

  describe "new session" do
    setup [:create_users]

    test "renders sell auction form", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)
      conn = get(conn, Routes.sell_path(conn, :new))
      assert html_response(conn, 200) =~ "New listing"
    end

    test "unauthenticated if unauthenticated", %{conn: conn} do
      conn = get(conn, Routes.sell_path(conn, :new))
      assert text_response(conn, 401) =~ "unauthenticated"
    end
  end

  describe "create" do
    setup [:create_users]

    test "creates auction if data is valid", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)
      post(conn, Routes.sell_path(conn, :create), auction: @auction_attrs, datetime: MockDateTime)
      [auction] = Auctions.get_sellers_auctions!(user)
      {:ok, start} = DateTime.from_naive(~N[2019-01-01 10:00:00], "Etc/UTC")
      {:ok, finish} = DateTime.from_naive(~N[2019-02-01 10:00:00], "Etc/UTC")
      assert auction.start == start
      assert auction.finish == finish
      assert auction.name == "some name"
      assert auction.description == "some description"
      assert auction.initial_price == Decimal.from_float(120.5)
      assert auction.user_id == user.id
    end

    test "renders seller index when data is valid", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)

      conn =
        post(conn, Routes.sell_path(conn, :create),
          auction: @auction_attrs,
          datetime: MockDateTime
        )

      assert get_flash(conn, :info) == "Listing successfully added"
      assert redirected_to(conn) == Routes.sell_path(conn, :sell)
    end

    test "renders error when create auction fails", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)

      conn =
        post(conn, Routes.sell_path(conn, :create),
          auction: @price_invalid_attrs,
          datetime: MockDateTime
        )

      assert get_flash(conn, :error) == "Form submission invalid"
      assert redirected_to(conn) == Routes.sell_path(conn, :new)
    end

    test "renders error when start date is invalid", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)
      conn = post(conn, Routes.sell_path(conn, :create), auction: @nil_auction_attrs)
      assert get_flash(conn, :error) == "All fields required"
      assert redirected_to(conn) == Routes.sell_path(conn, :new)
    end

    test "renders error when data is missing", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)
      conn = post(conn, Routes.sell_path(conn, :create), auction: @nil_auction_attrs)
      assert get_flash(conn, :error) == "All fields required"
      assert redirected_to(conn) == Routes.sell_path(conn, :new)
    end
  end

  describe "delete" do
    setup [:create_users]

    test "deletes auction", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)
      post(conn, Routes.sell_path(conn, :create), auction: @auction_attrs, datetime: MockDateTime)
      [auction] = Auctions.get_sellers_auctions!(user)
      delete(conn, Routes.sell_path(conn, :delete, auction.id))
      assert Auctions.get_sellers_auctions!(user) == []
    end

    test "renders seller index if delete is successful", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)
      post(conn, Routes.sell_path(conn, :create), auction: @auction_attrs, datetime: MockDateTime)
      [auction] = Auctions.get_sellers_auctions!(user)
      conn = delete(conn, Routes.sell_path(conn, :delete, auction.id))
      assert get_flash(conn, :info) == "Listing successfully deleted"
      assert redirected_to(conn) == Routes.sell_path(conn, :sell)
    end
  end

  defp create_users(_) do
    {:ok, user: fixture(:user, @user_attrs), other_user: fixture(:user, @other_user_attrs)}
  end
end
