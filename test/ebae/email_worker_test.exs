defmodule Ebae.EmailWorkerTest do
  use Ebae.DataCase
  use Bamboo.Test

  alias Ebae.{Accounts, Auctions, Email, EmailWorker}

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

  @bid_attrs %{offer: "120.5"}

  @user_attrs %{
    "username" => "username",
    "credential" => %{email: "email", password: "password"}
  }
  @other_user_attrs %{
    "username" => "other username",
    "credential" => %{email: "other email", password: "password"}
  }

  describe "perform" do
    test "sends the email to the auction winner" do
      {:ok, user} = Accounts.create_user(@user_attrs)
      {:ok, other_user} = Accounts.create_user(@other_user_attrs)
      {:ok, auction} = Auctions.create_auction(Map.put(@auction_attrs, "user_id", user.id), MockDateTimePast)
      Auctions.create_bid(Map.merge(@bid_attrs, %{user_id: other_user.id, auction_id: auction.id}))

      EmailWorker.perform(auction.id)

      expected_email = Email.won_email(other_user, auction.name)
      assert_delivered_email expected_email
    end

    test "returns no_winner no bids were placed" do
      {:ok, user} = Accounts.create_user(@user_attrs)
      {:ok, other_user} = Accounts.create_user(@other_user_attrs)
      {:ok, auction} = Auctions.create_auction(Map.put(@auction_attrs, "user_id", user.id), MockDateTimePast)

      assert EmailWorker.perform(auction.id) == :no_winner
    end
  end
end
