defmodule Ebae.Auction.Item do
  use Ecto.Schema

  import Ecto.Changeset

  alias Ebae.Accounts.User

  schema "items" do
    field :available, :boolean, default: false
    field :description, :string
    field :initial_price, :decimal
    field :name, :string
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:name, :description, :available, :initial_price, :user_id])
    |> validate_required([:name, :description, :available, :initial_price, :user_id])
  end
end
