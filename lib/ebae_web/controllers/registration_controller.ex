defmodule EbaeWeb.RegistrationController do
  use EbaeWeb, :controller

  alias EbaeWeb.Auth
  alias Ebae.{Accounts, Accounts.User}

  def new(conn, _) do
    if Auth.authenticated?(conn) do
      conn
      |> put_flash(:info, "Already signed in")
      |> redirect(to: Routes.page_path(conn, :index))
    else
      render(conn, "new.html",
        changeset: Accounts.change_user(%User{}),
        action: Routes.registration_path(conn, :create)
      )
    end
  end

  def create(conn, %{"user" => user}) do
    Accounts.create_user(user)
    |> signup_reply(conn)
  end

  def signup_reply({:ok, user}, conn) do
    conn
    |> put_flash(:info, "Welcome")
    |> Auth.sign_in(user)
    |> redirect(to: Routes.page_path(conn, :index))
  end

  def signup_reply({:error, changeset}, conn) do
    with reason <- error_from(changeset),
         conn <- put_flash(conn, :error, reason) do
      redirect(conn, to: Routes.registration_path(conn, :new))
    end
  end

  defp error_from(%Ecto.Changeset{errors: [username: _error]}) do
    "Username unavailable"
  end

  defp error_from(%Ecto.Changeset{
         changes: %{credential: %Ecto.Changeset{errors: [email: _error]}}
       }) do
    "Email unavailable"
  end
end
