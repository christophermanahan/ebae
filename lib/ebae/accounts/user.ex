defmodule Ebae.Accounts.User do
  use Ecto.Schema

  import Ecto.Changeset

  alias Ebae.{Accounts.Credential, Auction.Item}

  schema "users" do
    field :username, :string
    has_one :credential, Credential, on_replace: :update
    has_many :items, Item

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username])
    |> validate_required([:username])
    |> unique_constraint(:username)
  end
end
