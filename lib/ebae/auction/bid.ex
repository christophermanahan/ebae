defmodule Ebae.Auction.Bid do
  use Ecto.Schema
  import Ecto.Changeset

  alias Ebae.{Accounts.User, Auction.Item}

  schema "bids" do
    field :offer, :decimal
    belongs_to :user, User
    belongs_to :item, Item

    timestamps()
  end

  @doc false
  def changeset(bid, attrs) do
    bid
    |> cast(attrs, [:offer, :user_id, :item_id])
    |> validate_required([:offer, :user_id, :item_id])
  end
end
