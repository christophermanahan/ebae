defmodule Ebae.Auctions do
  import Ecto.Query, warn: false

  alias Ebae.Repo
  alias Ebae.{Auctions.Auction, Auctions.Bid, Accounts.User}

  def get_auction!(id) do
    Auction
    |> Repo.get!(id)
    |> Repo.preload([bids: from(b in Bid, order_by: [desc: b.offer])])
  end

  def get_sellers_auctions!(%User{} = user) do
    Repo.all(from a in Auction, where: a.user_id == ^user.id)
  end

  def get_buyers_auctions!(%User{} = user) do
    Repo.all(from i in Auction, where: i.user_id != ^user.id)
    |> Repo.preload([bids: from(b in Bid, order_by: [desc: b.offer])])
  end

  def create_auction(attrs, datetime \\ DateTime) do
    if validate_datetimes(attrs, datetime) do
      %Auction{}
      |> Auction.changeset(attrs)
      |> Repo.insert()
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
