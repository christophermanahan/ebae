defmodule Ebae.Auctions.Bid do
  use Ecto.Schema
  import Ecto.Changeset

  alias Ebae.{Accounts.User, Auctions.Auction}

  schema "bids" do
    field :offer, :decimal
    belongs_to :user, User
    belongs_to :auction, Auction

    timestamps()
  end

  def changeset(bid, attrs) do
    bid
    |> cast(attrs, [:offer, :user_id, :auction_id])
    |> validate_required([:offer, :user_id, :auction_id])
  end
end
