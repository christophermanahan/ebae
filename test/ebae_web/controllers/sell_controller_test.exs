defmodule EbaeWeb.SellControllerTest do
  use EbaeWeb.ConnCase
  use Phoenix.HTML

  alias Ebae.{Accounts, Auctions}

  @auction_attrs %{
    name: "auction",
    description: "description",
    initial_price: 100.01
  }
  @price_invalid_attrs %{
    name: "auction",
    description: "description",
    initial_price: "invalid string"
  }
  @nil_auction_attrs %{description: "", initial_price: "", name: ""}

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

  describe "index" do
    setup [:create_users]

    test "renders seller greeting page", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)
      conn = get(conn, Routes.sell_path(conn, :index))
      assert html_response(conn, 200) =~ "Your current auctions"
    end
  end

  describe "auction" do
    setup [:create_users]

    test "renders auction details page", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)
      post(conn, Routes.sell_path(conn, :create), auction: @auction_attrs)
      [auction] = Auctions.get_sellers_auctions!(user)
      conn = get(conn, Routes.sell_path(conn, :auction, auction.id))
      assert html_response(conn, 200) =~ "Auction details"
    end

    test "renders error if auction does not belong to seller", %{conn: conn, user: user, other_user: other_user} do
      conn = Auth.sign_in(conn, user)
      {:ok, auction} = Auctions.create_auction(Map.put(@auction_attrs, :user_id, other_user.id))
      conn = get(conn, Routes.sell_path(conn, :auction, auction.id))
      assert get_flash(conn, :error) == "Invalid auction"
      assert redirected_to(conn) == Routes.sell_path(conn, :index)
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
      post(conn, Routes.sell_path(conn, :create), auction: @auction_attrs)
      [auction] = Auctions.get_sellers_auctions!(user)
      assert auction.name == "auction"
      assert auction.description == "description"
      assert auction.initial_price == Decimal.from_float(100.01)
      assert auction.available == true
      assert auction.user_id == user.id
    end

    test "renders seller index when data is valid", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)
      conn = post(conn, Routes.sell_path(conn, :create), auction: @auction_attrs)
      assert get_flash(conn, :info) == "Listing successfully added"
      assert redirected_to(conn) == Routes.sell_path(conn, :index)
    end

    test "renders error when create auction fails", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)
      conn = post(conn, Routes.sell_path(conn, :create), auction: @price_invalid_attrs)
      assert get_flash(conn, :error) == "Form submission invalid"
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
      post(conn, Routes.sell_path(conn, :create), auction: @auction_attrs)
      [auction] = Auctions.get_sellers_auctions!(user)
      delete(conn, Routes.sell_path(conn, :delete, auction.id))
      assert Auctions.get_sellers_auctions!(user) == []
    end

    test "renders seller index if delete is successful", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)
      post(conn, Routes.sell_path(conn, :create), auction: @auction_attrs)
      [auction] = Auctions.get_sellers_auctions!(user)
      conn = delete(conn, Routes.sell_path(conn, :delete, auction.id))
      assert get_flash(conn, :info) == "Listing successfully deleted"
      assert redirected_to(conn) == Routes.sell_path(conn, :index)
    end
  end

  defp create_users(_) do
    {:ok, user: fixture(:user, @user_attrs), other_user: fixture(:user, @other_user_attrs)}
  end
end
