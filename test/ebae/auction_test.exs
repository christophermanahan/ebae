defmodule Ebae.AuctionsTest do
  use Ebae.DataCase

  alias Ebae.{Auctions, Accounts, Auctions.Auction, Auctions.Bid}

  @auction_attrs %{
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
  @invalid_auction_attrs %{
    available: nil,
    description: nil,
    initial_price: nil,
    name: nil,
    user_id: nil
  }

  @user_attrs %{
    username: "username",
    credential: %{email: "email", password: "password"}
  }

  @other_user_auction_attrs %{
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
  @invalid_bid_attrs %{offer: nil, user_id: nil, auction_id: nil}

  def fixture(:auction, user_id) do
    {:ok, auction} = Auctions.create_auction(Map.put(@auction_attrs, :user_id, user_id))
    auction
  end

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@user_attrs)
    user
  end

  def fixture(:bid, user_id, auction_id) do
    {:ok, bid} =
      Auctions.create_bid(Map.merge(@bid_attrs, %{user_id: user_id, auction_id: auction_id}))

    bid
  end

  describe "auctions" do
    setup [:create_user]

    test "get_auction!/1 returns the auction with given id", %{user: user} do
      auction = fixture(:auction, user.id)
      auction = Auctions.get_auction!(auction.id)
      assert auction.available == true
      assert auction.description == "some description"
      assert auction.initial_price == Decimal.new("120.5")
      assert auction.name == "some name"
      assert auction.user_id == user.id
      assert auction.bids == []
    end

    test "get_sellers_auctions!/1 returns the auctions belonging to a given seller", %{user: user} do
      fixture(:auction, user.id)
      [auction] = Auctions.get_sellers_auctions!(user)
      assert auction.available == true
      assert auction.description == "some description"
      assert auction.initial_price == Decimal.new("120.5")
      assert auction.name == "some name"
      assert auction.user_id == user.id
    end

    test "get_buyers_auctions!/1 returns the auctions that are for sale", %{user: user} do
      Auctions.create_auction(Map.put(@auction_attrs, :user_id, user.id))

      {:ok, other_user} = Accounts.create_user(@other_user_attrs)
      Auctions.create_auction(Map.put(@other_user_auction_attrs, :user_id, other_user.id))
      [auction] = Auctions.get_buyers_auctions!(user)
      assert auction.available == true
      assert auction.description == "some other description"
      assert auction.initial_price == Decimal.new("1.00")
      assert auction.name == "some other name"
      assert auction.user_id == other_user.id
      assert auction.bids == []
    end

    test "create_auction/1 with valid data creates an auction", %{user: user} do
      assert {:ok, %Auction{} = auction} =
               Auctions.create_auction(Map.put(@auction_attrs, :user_id, user.id))

      assert auction.available == true
      assert auction.description == "some description"
      assert auction.initial_price == Decimal.new("120.5")
      assert auction.name == "some name"
      assert auction.user_id == user.id
    end

    test "create_auction/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Auctions.create_auction(@invalid_auction_attrs)
    end

    test "update_auction/2 with valid data updates the auction", %{user: user} do
      auction = fixture(:auction, user.id)
      assert {:ok, %Auction{} = auction} = Auctions.update_auction(auction, @update_attrs)
      assert auction.available == false
      assert auction.description == "some updated description"
      assert auction.initial_price == Decimal.new("456.7")
      assert auction.name == "some updated name"
    end

    test "update_auction/2 with invalid data returns error changeset", %{user: user} do
      auction = fixture(:auction, user.id)

      assert {:error, %Ecto.Changeset{}} =
               Auctions.update_auction(auction, @invalid_auction_attrs)
    end

    test "delete_auction/1 deletes the auction", %{user: user} do
      auction = fixture(:auction, user.id)
      assert {:ok, %Auction{}} = Auctions.delete_auction(auction)
      assert_raise Ecto.NoResultsError, fn -> Auctions.get_auction!(auction.id) end
    end

    test "change_auction/1 returns a auction changeset", %{user: user} do
      auction = fixture(:auction, user.id)
      assert %Ecto.Changeset{} = Auctions.change_auction(auction)
    end
  end

  describe "bids" do
    setup [:create_user]

    test "get_bid!/1 returns the bid with given id", %{user: user} do
      auction = fixture(:auction, user.id)
      bid = fixture(:bid, user.id, auction.id)
      assert Auctions.get_bid!(bid.id) == bid
    end

    test "get_bids!/1 returns the user's bids", %{user: user} do
      auction = fixture(:auction, user.id)
      bid = fixture(:bid, user.id, auction.id)
      assert Auctions.get_bids!(user) == [bid]
    end

    test "create_bid/1 with valid data creates a bid", %{user: user} do
      auction = fixture(:auction, user.id)

      assert {:ok, %Bid{} = bid} =
               Auctions.create_bid(
                 Map.merge(@bid_attrs, %{user_id: user.id, auction_id: auction.id})
               )

      assert bid.offer == Decimal.new("120.5")
    end

    test "create_bid/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Auctions.create_bid(@invalid_bid_attrs)
    end

    test "change_bid/1 returns a bid changeset", %{user: user} do
      auction = fixture(:auction, user.id)
      bid = fixture(:bid, user.id, auction.id)
      assert %Ecto.Changeset{} = Auctions.change_bid(bid)
    end
  end

  defp create_user(_) do
    {:ok, user: fixture(:user)}
  end
end
