defmodule Ebae.Auctions.Auction do
  use Ecto.Schema

  import Ecto.Changeset

  alias Ebae.{Accounts.User, Auctions.Bid}

  schema "auctions" do
    field :available, :boolean, default: true
    field :description, :string
    field :initial_price, :decimal
    field :name, :string
    belongs_to :user, User
    has_many :bids, Bid

    timestamps()
  end

  def changeset(auction, attrs) do
    auction
    |> cast(attrs, [:name, :description, :available, :initial_price, :user_id])
    |> validate_required([:name, :description, :available, :initial_price, :user_id])
  end
end