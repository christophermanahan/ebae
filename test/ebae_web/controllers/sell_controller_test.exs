defmodule EbaeWeb.SellControllerTest do
  use EbaeWeb.ConnCase
  use Phoenix.HTML

  alias Ebae.{Accounts, Auction}

  @item_attrs %{
    name: "item",
    description: "description",
    initial_price: 100.01
  }
  @invalid_attrs %{description: "", initial_price: "", name: ""}

  @user_attrs %{
    username: "username",
    credential: %{email: "email", password: "password"}
  }

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@user_attrs)
    user
  end

  describe "index" do
    setup [:create_user]

    test "renders seller greeting page", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)
      conn = get(conn, Routes.sell_path(conn, :index))
      assert html_response(conn, 200) =~ "Your current listings"
    end

    test "displays add listing", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)
      conn = get(conn, Routes.sell_path(conn, :index))

      assert html_response(conn, 200) =~
               safe_to_string(
                 link("Add listing", to: Routes.sell_path(conn, :new, class: "nav-link"))
               )
    end
  end

  describe "new session" do
    setup [:create_user]

    test "renders sell item form", %{conn: conn, user: user} do
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
    setup [:create_user]

    test "creates item if data is valid", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)
      post(conn, Routes.sell_path(conn, :create), item: @item_attrs)
      [item] = Auction.get_items!(user)
      assert item.name == "item"
      assert item.description == "description"
      assert item.initial_price == Decimal.from_float(100.01)
      assert item.available == true
      assert item.user_id == user.id
    end

    test "renders seller index when data is valid", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)
      conn = post(conn, Routes.sell_path(conn, :create), item: @item_attrs)
      assert get_flash(conn, :info) == "Listing successfully added"
      assert redirected_to(conn) == Routes.sell_path(conn, :index)
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)
      conn = post(conn, Routes.sell_path(conn, :create), item: @invalid_attrs)
      assert get_flash(conn, :error) == "All fields required"
      assert redirected_to(conn) == Routes.sell_path(conn, :new)
    end
  end

  defp create_user(_) do
    {:ok, user: fixture(:user)}
  end
end
