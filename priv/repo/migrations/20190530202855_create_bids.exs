defmodule Ebae.Repo.Migrations.CreateBids do
  use Ecto.Migration

  def change do
    create table(:bids) do
      add :offer, :decimal
      add :user_id, references(:users, on_delete: :nothing), null: false
      add :auction_id, references(:auctions, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:bids, [:user_id])
    create index(:bids, [:auction_id])
  end
end
