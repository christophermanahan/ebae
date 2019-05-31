defmodule Ebae.AuctionTest do
  use Ebae.DataCase

  alias Ebae.{Auction, Accounts, Auction.Item, Auction.Bid}

  @item_attrs %{
    available: true,
    description: "some description",
    initial_price: "120.5",
    name: "some name"
  }
  @update_attrs %{
    available: false,
    description: "some updated description",
    initial_price: "456.7",
    name: "some updated name"
  }
  @invalid_item_attrs %{available: nil, description: nil, initial_price: nil, name: nil, user_id: nil}

  @user_attrs %{
    username: "username",
    credential: %{email: "email", password: "password"}
  }

  @other_user_item_attrs %{
    available: true,
    description: "some other description",
    initial_price: "1.00",
    name: "some other name"
  }

  @other_user_attrs %{
    username: "other username",
    credential: %{email: "other email", password: "password"}
  }

  @bid_attrs %{offer: "120.5"}
  @invalid_bid_attrs %{offer: nil, user_id: nil, item_id: nil}

  def fixture(:item, user_id) do
    {:ok, item} = Auction.create_item(Map.put(@item_attrs, :user_id, user_id))
    item
  end

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@user_attrs)
    user
  end

  def fixture(:bid, user_id, item_id) do
    {:ok, bid} = Auction.create_bid(Map.merge(@bid_attrs, %{user_id: user_id, item_id: item_id}))
    bid
  end

  describe "items" do
    setup [:create_user]

    test "list_items/0 returns all items", %{user: user} do
      item = fixture(:item, user.id)
      assert Auction.list_items() == [item]
    end

    test "get_item!/1 returns the item with given id", %{user: user} do
      item = fixture(:item, user.id)
      assert Auction.get_item!(item.id) == item
    end

    test "get_sellers_items!/1 returns the items belonging to a given seller", %{user: user} do
      item = fixture(:item, user.id)
      assert Auction.get_sellers_items!(user) == [item]
    end

    test "get_buyers_items!/1 returns the items that are for sale", %{user: user} do
      Auction.create_item(Map.put(@item_attrs, :user_id, user.id))

      {:ok, other_user} = Accounts.create_user(@other_user_attrs)
      {:ok, other_users_item} =
        Auction.create_item(Map.put(@other_user_item_attrs, :user_id, other_user.id))

      assert Auction.get_buyers_items!(user) == [other_users_item]
    end

    test "create_item/1 with valid data creates an item", %{user: user} do
      assert {:ok, %Item{} = item} =
               Auction.create_item(Map.put(@item_attrs, :user_id, user.id))
      assert item.available == true
      assert item.description == "some description"
      assert item.initial_price == Decimal.new("120.5")
      assert item.name == "some name"
      assert item.user_id == user.id
    end

    test "create_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Auction.create_item(@invalid_item_attrs)
    end

    test "update_item/2 with valid data updates the item", %{user: user} do
      item = fixture(:item, user.id)
      assert {:ok, %Item{} = item} = Auction.update_item(item, @update_attrs)
      assert item.available == false
      assert item.description == "some updated description"
      assert item.initial_price == Decimal.new("456.7")
      assert item.name == "some updated name"
    end

    test "update_item/2 with invalid data returns error changeset", %{user: user} do
      item = fixture(:item, user.id)
      assert {:error, %Ecto.Changeset{}} = Auction.update_item(item, @invalid_item_attrs)
      assert item == Auction.get_item!(item.id)
    end

    test "delete_item/1 deletes the item", %{user: user} do
      item = fixture(:item, user.id)
      assert {:ok, %Item{}} = Auction.delete_item(item)
      assert_raise Ecto.NoResultsError, fn -> Auction.get_item!(item.id) end
    end

    test "change_item/1 returns a item changeset", %{user: user} do
      item = fixture(:item, user.id)
      assert %Ecto.Changeset{} = Auction.change_item(item)
    end
  end

  describe "bids" do
    setup [:create_user]

    test "get_bid!/1 returns the bid with given id", %{user: user} do
      item = fixture(:item, user.id)
      bid = fixture(:bid, user.id, item.id)
      assert Auction.get_bid!(bid.id) == bid
    end

    test "create_bid/1 with valid data creates a bid", %{user: user} do
      item = fixture(:item, user.id)
      assert {:ok, %Bid{} = bid} = Auction.create_bid(Map.merge(@bid_attrs, %{user_id: user.id, item_id: item.id}))
      assert bid.offer == Decimal.new("120.5")
    end

    test "create_bid/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Auction.create_bid(@invalid_bid_attrs)
    end

    test "change_bid/1 returns a bid changeset", %{user: user} do
      item = fixture(:item, user.id)
      bid = fixture(:bid, user.id, item.id)
      assert %Ecto.Changeset{} = Auction.change_bid(bid)
    end
  end

  defp create_user(_) do
    {:ok, user: fixture(:user)}
  end
end
