defmodule Ebae.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items) do
      add :name, :string
      add :description, :string
      add :available, :boolean, default: false, null: false
      add :initial_price, :decimal
      add :user_id, references(:users, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:items, [:user_id])
  end
end
