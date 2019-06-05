defmodule Ebae.Auctions.Auction do
  use Ecto.Schema

  import Ecto.Changeset

  alias Ebae.{Accounts.User, Auctions.Bid}

  schema "auctions" do
    field :start, :utc_datetime
    field :finish, :utc_datetime
    field :description, :string
    field :initial_price, :decimal
    field :name, :string
    belongs_to :user, User
    has_many :bids, Bid

    timestamps()
  end

  def changeset(changeset, attrs) do
    changeset
    |> cast(attrs, [:name, :description, :start, :finish, :initial_price, :user_id])
    |> validate_required([:name, :description, :start, :finish, :initial_price, :user_id])
  end
end
