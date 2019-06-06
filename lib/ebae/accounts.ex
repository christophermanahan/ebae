defmodule Ebae.Accounts do
  import Ecto.Query, warn: false

  alias Ebae.Repo
  alias Ebae.Accounts.{User, Credential}

  def get_user!(id) do
    User
    |> Repo.get!(id)
    |> Repo.preload(:credential)
  end

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Ecto.Changeset.cast_assoc(:credential, with: &Credential.changeset/2)
    |> Repo.insert()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  def authenticate_user(username, plain_text_password) do
    with user = %Ebae.Accounts.User{} <- get_user(username),
         true <- Argon2.verify_pass(plain_text_password, user.credential.password) do
      {:ok, user}
    else
      _err -> {:error, :invalid_credentials}
    end
  end

  defp get_user(username) do
    Repo.one(from u in User, where: u.username == ^username)
    |> Repo.preload(:credential)
  end
end
