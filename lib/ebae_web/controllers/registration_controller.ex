defmodule EbaeWeb.RegistrationController do
  use EbaeWeb, :controller

  alias Ebae.{Accounts, Accounts.User, Accounts.Guardian}

  def new(conn, _) do
    if authenticated?(conn) do
      conn
      |> put_flash(:info, "Already signed in")
      |> redirect(to: "/")
    else
      render(conn, "new.html",
        changeset: user_changeset(),
        action: Routes.registration_path(conn, :create)
      )
    end
  end

  defp authenticated?(conn) do
    Guardian.Plug.authenticated?(conn)
  end

  defp user_changeset() do
    Accounts.change_user(%User{})
  end

  def create(conn, %{"user" => user}) do
    Accounts.create_user(user)
    |> signup_reply(conn)
  end

  def signup_reply({:ok, user}, conn) do
    conn
    |> put_flash(:info, "Welcome")
    |> Guardian.Plug.sign_in(user)
    |> redirect(to: "/")
  end

  def signup_reply({:error, changeset}, conn) do
    with reason <- error_from(changeset),
         conn <- put_flash(conn, :error, reason) do
      redirect(conn, to: "/signup")
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
