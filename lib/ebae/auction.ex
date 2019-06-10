defmodule Ebae.Auctions do
  import Ecto.Query, warn: false

  alias Ebae.Repo
  alias Ebae.{Auctions.Auction, Auctions.Bid, Accounts, Accounts.User, Scheduler, EmailWorker}

  def get_auction!(id) do
    Auction
    |> Repo.get!(id)
    |> Repo.preload(bids: from(b in Bid, order_by: [desc: b.offer]))
  end

  def get_sellers_auctions!(%User{} = user, datetime \\ DateTime) do
    now = datetime.utc_now

    Repo.all(
      from a in Auction, where: a.user_id == ^user.id and a.start < ^now and a.finish > ^now
    )
    |> Repo.preload(bids: from(b in Bid, order_by: [desc: b.offer]))
  end

  def get_buyers_auctions!(%User{} = user, datetime \\ DateTime) do
    now = datetime.utc_now

    Repo.all(
      from a in Auction, where: a.user_id != ^user.id and a.start < ^now and a.finish > ^now
    )
    |> Repo.preload(bids: from(b in Bid, order_by: [desc: b.offer]))
  end

  def won!(%User{} = user, datetime \\ DateTime) do
    now = datetime.utc_now

    Repo.all(
      from a in Auction, where: a.user_id != ^user.id and a.start < ^now and a.finish < ^now
    )
    |> Repo.preload(bids: from(b in Bid, order_by: [desc: b.offer]))
    |> Enum.filter(fn auction -> Enum.at(auction.bids, 0).user_id == user.id end)
  end

  def sold!(%User{} = user, datetime \\ DateTime) do
    now = datetime.utc_now

    Repo.all(
      from a in Auction, where: a.user_id == ^user.id and a.start < ^now and a.finish < ^now
    )
    |> Repo.preload(bids: from(b in Bid, order_by: [desc: b.offer]))
    |> Enum.filter(fn auction -> Enum.count(auction.bids) > 0 end)
  end

  def highest_bidder(auction_id) do
    auction_id
    |> get_auction!()
    |> Map.get(:bids)
    |> Enum.at(0)
    |> Map.get(:user_id)
    |> Accounts.get_user!()
  end

  def create_auction(attrs, datetime \\ DateTime, scheduler \\ Scheduler) do
    if validate_datetimes(attrs, datetime) do
      result = %Auction{}
      |> Auction.changeset(attrs)
      |> Repo.insert()
      # case result do
      #   {:ok, auction} ->
      #     scheduler.notify(auction)
      #     result
      #   error -> error
      # end
    else
      {:error, :datetime}
    end
  end

  defp validate_datetimes(%{"start" => start, "finish" => finish}, datetime) do
    now = datetime.utc_now

    datetime.compare(start, finish) == :lt &&
      datetime.compare(now, start) == :lt &&
      datetime.compare(now, finish) == :lt
  end

  def update_auction(%Auction{} = auction, attrs) do
    auction
    |> Auction.changeset(attrs)
    |> Repo.update()
  end

  def delete_auction(%Auction{} = auction) do
    Repo.delete(auction)
  end

  def change_auction(%Auction{} = auction) do
    Auction.changeset(auction, %{})
  end

  def get_bid!(id), do: Repo.get!(Bid, id)

  def get_bids!(%User{} = user) do
    Repo.all(from b in Bid, where: b.user_id == ^user.id)
    |> Repo.preload(:auction)
  end

  def create_bid(attrs \\ %{}) do
    %Bid{}
    |> Bid.changeset(attrs)
    |> Repo.insert()
  end

  def change_bid(%Bid{} = bid) do
    Bid.changeset(bid, %{})
  end
end
