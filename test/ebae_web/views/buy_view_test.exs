defmodule EbaeWeb.BuyViewTest do
  use EbaeWeb.ConnCase, async: true

  alias Ebae.{Accounts, Auctions}
  alias EbaeWeb.BuyView

  @auction_attrs %{
    available: true,
    description: "some description",
    initial_price: "120.50",
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

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@user_attrs)
    user
  end

  describe "username" do
    setup [:create_user]

    test "returns the current user", %{conn: conn, user: user} do
      conn = Auth.sign_in(conn, user)
      assert BuyView.username(conn) == user.username
    end
  end

  describe "auctions" do
    setup [:create_user]

    test "returns the current auctions for sale", %{conn: conn, user: user} do
      {:ok, other_user} = Accounts.create_user(@other_user_attrs)
      Auctions.create_auction(Map.put(@auction_attrs, :user_id, other_user.id))
      conn = Auth.sign_in(conn, user)
      auctions = Auctions.get_buyers_auctions!(user)
      assert BuyView.auctions(conn) == auctions
    end
  end

  defp create_user(_) do
    {:ok, user: fixture(:user)}
  end
end
