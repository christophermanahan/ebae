defmodule Ebae.Repo.Migrations.CreateAuctions do
  use Ecto.Migration

  def change do
    create table(:auctions) do
      add :name, :string
      add :description, :string
      add :start, :utc_datetime
      add :finish, :utc_datetime
      add :initial_price, :decimal
      add :user_id, references(:users, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:auctions, [:user_id])
  end
end
