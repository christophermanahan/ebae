defmodule EbaeWeb.SessionController do
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
        action: Routes.session_path(conn, :create)
      )
    end
  end

  defp authenticated?(conn) do
    Guardian.Plug.authenticated?(conn)
  end

  defp user_changeset() do
    Accounts.change_user(%User{})
  end

  def create(conn, %{
        "user" => %{"username" => username, "credential" => %{"password" => password}}
      }) do
    Accounts.authenticate_user(username, password)
    |> signin_reply(conn)
  end

  def delete(conn, _) do
    conn
    |> put_flash(:info, "Farewell")
    |> Guardian.Plug.sign_out()
    |> redirect(to: "/signin")
  end

  defp signin_reply({:ok, user}, conn) do
    conn
    |> put_flash(:info, "Welcome back")
    |> Guardian.Plug.sign_in(user)
    |> redirect(to: "/")
  end

  defp signin_reply({:error, _}, conn) do
    conn
    |> put_flash(:error, "Invalid credentials")
    |> redirect(to: Routes.session_path(conn, :new))
  end
end
