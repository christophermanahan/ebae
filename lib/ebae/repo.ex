defmodule Ebae.Repo do
  use Ecto.Repo,
    otp_app: :ebae,
    adapter: Ecto.Adapters.Postgres
end
