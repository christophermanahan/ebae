defmodule Ebae.AuctionsTest do
  use Ebae.DataCase

  alias Ebae.{Auctions, Accounts, Auctions.Auction, Auctions.Bid}

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
  {:ok, started} = DateTime.from_naive(~N[2017-01-01 10:00:00], "Etc/UTC")
  {:ok, finished} = DateTime.from_naive(~N[2017-02-01 10:00:00], "Etc/UTC")
  {:ok, past_date} = DateTime.from_naive(~N[2017-01-01 10:00:00], "Etc/UTC")

  @auction_attrs %{
    "start" => start,
    "finish" => finish,
    "description" => "some description",
    "initial_price" => "120.5",
    "name" => "some name"
  }
  @update_attrs %{
    "start" => start,
    "finish" => finish,
    "description" => "some updated description",
    "initial_price" => "456.7",
    "name" => "some updated name"
  }
  @invalid_auction_start %{
    "start" => past_date,
    "finish" => finish,
    "description" => "some description",
    "initial_price" => "120.5",
    "name" => "some name"
  }
  @other_auction_attrs %{
    "start" => start,
    "finish" => finish,
    "description" => "some other description",
    "initial_price" => "1.00",
    "name" => "some other name"
  }
  @past_auction_attrs %{
    "start" => started,
    "finish" => finished,
    "description" => "some other description",
    "initial_price" => "1.00",
    "name" => "some other name"
  }

  @user_attrs %{
    "username" => "username",
    "credential" => %{email: "email", password: "password"}
  }
  @other_user_attrs %{
    "username" => "other username",
    "credential" => %{email: "other email", password: "password"}
  }
  @another_user_attrs %{
    "username" => "another username",
    "credential" => %{email: "another email", password: "password"}
  }

  @bid_attrs %{offer: "120.5"}
  @higher_bid_attrs %{offer: "130.5"}
  @invalid_bid_attrs %{offer: nil, user_id: nil, auction_id: nil}

  def fixture(:auction, user_id) do
    {:ok, auction} =
      Auctions.create_auction(Map.put(@auction_attrs, "user_id", user_id), MockDateTimePast)

    auction
  end

  def fixture(:user, attrs) do
    {:ok, user} = Accounts.create_user(attrs)
    user
  end

  def fixture(:bid, attrs, user_id, auction_id) do
    {:ok, bid} =
      Auctions.create_bid(Map.merge(attrs, %{user_id: user_id, auction_id: auction_id}))

    bid
  end

  describe "auctions" do
    setup [:create_users]

    test "get_auction!/1 returns the auction with given id", %{user: user} do
      auction = fixture(:auction, user.id)
      auction = Auctions.get_auction!(auction.id)
      {:ok, start} = DateTime.from_naive(~N[2019-01-01 10:00:00], "Etc/UTC")
      {:ok, finish} = DateTime.from_naive(~N[2019-02-01 10:00:00], "Etc/UTC")
      assert auction.start == start
      assert auction.finish == finish
      assert auction.description == "some description"
      assert auction.initial_price == Decimal.new("120.5")
      assert auction.name == "some name"
      assert auction.user_id == user.id
      assert auction.bids == []
    end

    test "get_auction!/1 returns the auction with sorted bids", %{
      user: user,
      other_user: other_user
    } do
      auction = fixture(:auction, other_user.id)
      lower_bid = fixture(:bid, @bid_attrs, user.id, auction.id)
      higher_bid = fixture(:bid, @higher_bid_attrs, user.id, auction.id)
      auction = Auctions.get_auction!(auction.id)
      assert auction.bids == [higher_bid, lower_bid]
    end

    test "get_sellers_auctions!/1 returns the auctions belonging to a given seller", %{user: user} do
      fixture(:auction, user.id)
      [auction] = Auctions.get_sellers_auctions!(user)
      {:ok, start} = DateTime.from_naive(~N[2019-01-01 10:00:00], "Etc/UTC")
      {:ok, finish} = DateTime.from_naive(~N[2019-02-01 10:00:00], "Etc/UTC")
      assert auction.start == start
      assert auction.finish == finish
      assert auction.description == "some description"
      assert auction.initial_price == Decimal.new("120.5")
      assert auction.name == "some name"
      assert auction.user_id == user.id
    end

    test "get_buyers_auctions!/1 returns the auctions that are currently for sale", %{
      user: user,
      other_user: other_user
    } do
      Auctions.create_auction(Map.put(@auction_attrs, "user_id", user.id), MockDateTimePast)

      Auctions.create_auction(
        Map.put(@other_auction_attrs, "user_id", other_user.id),
        MockDateTimePast
      )
      Auctions.create_auction(
        Map.put(@past_auction_attrs, "user_id", other_user.id),
        MockDateTimePast
      )

      [auction] = Auctions.get_buyers_auctions!(user, MockDateTimePresent)
      {:ok, start} = DateTime.from_naive(~N[2019-01-01 10:00:00], "Etc/UTC")
      {:ok, finish} = DateTime.from_naive(~N[2019-02-01 10:00:00], "Etc/UTC")
      assert auction.start == start
      assert auction.finish == finish
      assert auction.description == "some other description"
      assert auction.initial_price == Decimal.new("1.00")
      assert auction.name == "some other name"
      assert auction.user_id == other_user.id
      assert auction.bids == []
    end

    test "get_buyers_auctions!/1 returns the auctions with sorted bids", %{
      user: user,
      other_user: other_user
    } do
      auction = fixture(:auction, other_user.id)
      lower_bid = fixture(:bid, @bid_attrs, user.id, auction.id)
      higher_bid = fixture(:bid, @higher_bid_attrs, user.id, auction.id)
      [auction] = Auctions.get_buyers_auctions!(user, MockDateTimePresent)
      assert auction.bids == [higher_bid, lower_bid]
    end

    test "won_auctions!/1 returns the auctions that have been won", %{
      user: user,
      other_user: other_user
    } do
      another_user = fixture(:user, @another_user_attrs)
      {:ok, auction_one} = Auctions.create_auction(Map.put(@auction_attrs, "user_id", other_user.id), MockDateTimePast)
      {:ok, auction_two} = Auctions.create_auction(Map.put(@other_auction_attrs, "user_id", other_user.id), MockDateTimePast)
      fixture(:bid, @bid_attrs, user.id, auction_one.id)
      fixture(:bid, @bid_attrs, user.id, auction_two.id)
      fixture(:bid, @higher_bid_attrs, another_user.id, auction_two.id)
      [auction] = Auctions.won!(user, MockDateTimeFuture)
      assert auction.name == auction_one.name
    end


    test "create_auction/1 with valid data creates an auction", %{user: user} do
      assert {:ok, %Auction{} = auction} =
               Auctions.create_auction(Map.put(@auction_attrs, "user_id", user.id), MockDateTimePast)

      {:ok, start} = DateTime.from_naive(~N[2019-01-01 10:00:00], "Etc/UTC")
      {:ok, finish} = DateTime.from_naive(~N[2019-02-01 10:00:00], "Etc/UTC")
      assert auction.start == start
      assert auction.finish == finish
      assert auction.description == "some description"
      assert auction.initial_price == Decimal.new("120.5")
      assert auction.name == "some name"
      assert auction.user_id == user.id
    end

    test "create_auction/1 with invalid start date returns error changeset", %{user: user} do
      assert {:error, changeset} =
               Auctions.create_auction(
                 Map.put(@invalid_auction_start, "user_id", user.id),
                 MockDateTimePast
               )
    end

    test "update_auction/2 with valid data updates the auction", %{user: user} do
      auction = fixture(:auction, user.id)
      assert {:ok, %Auction{} = auction} = Auctions.update_auction(auction, @update_attrs)
      {:ok, start} = DateTime.from_naive(~N[2019-01-01 10:00:00], "Etc/UTC")
      {:ok, finish} = DateTime.from_naive(~N[2019-02-01 10:00:00], "Etc/UTC")
      assert auction.start == start
      assert auction.finish == finish
      assert auction.description == "some updated description"
      assert auction.initial_price == Decimal.new("456.7")
      assert auction.name == "some updated name"
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
    setup [:create_users]

    test "get_bid!/1 returns the bid with given id", %{user: user} do
      auction = fixture(:auction, user.id)
      bid = fixture(:bid, @bid_attrs, user.id, auction.id)
      assert Auctions.get_bid!(bid.id) == bid
    end

    test "get_bids!/1 returns the user's bids", %{user: user} do
      auction = fixture(:auction, user.id)
      fixture(:bid, @bid_attrs, user.id, auction.id)
      [bid] = Auctions.get_bids!(user)
      assert bid.offer == Decimal.from_float(120.5)
      assert bid.auction == auction
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
      bid = fixture(:bid, @bid_attrs, user.id, auction.id)
      assert %Ecto.Changeset{} = Auctions.change_bid(bid)
    end
  end

  defp create_users(_) do
    {:ok, user: fixture(:user, @user_attrs), other_user: fixture(:user, @other_user_attrs)}
  end
end
