defmodule EbaeWeb.SellController do
  use EbaeWeb, :controller

  alias Ebae.{Auction, Auction.Item}
  alias EbaeWeb.Auth

  def new(conn, _) do
    render(conn, "new.html",
      changeset: Auction.change_item(%Item{}),
      action: Routes.sell_path(conn, :create)
    )
  end

  def index(conn, _) do
    render(conn, "index.html")
  end

  def delete(conn, %{"id" => id}) do
    Auction.get_item!(id)
    |> Auction.delete_item()
    |> delete_reply(conn)
  end

  defp delete_reply({:ok, _}, conn) do
    conn
    |> put_flash(:info, "Listing successfully deleted")
    |> redirect(to: Routes.sell_path(conn, :index))
  end

  def create(conn, %{"item" => item}) do
    conn
    |> validate_and_create(item)
    |> create_reply(conn)
  end

  defp validate_and_create(conn, item) do
    with true <- validate(item),
         user <- Auth.current_user(conn),
         id <- Map.get(user, :id),
         item <- Map.put(item, "user_id", id) do
      Auction.create_item(item)
    else
      _err -> :error
    end
  end

  defp validate(item) do
    Map.values(item)
    |> Enum.all?(fn key -> key != "" end)
  end

  defp create_reply({:ok, _}, conn) do
    conn
    |> put_flash(:info, "Listing successfully added")
    |> redirect(to: Routes.sell_path(conn, :index))
  end

  defp create_reply({:error, _}, conn) do
    conn
    |> put_flash(:error, "Form submission invalid")
    |> redirect(to: Routes.sell_path(conn, :new))
  end

  defp create_reply(:error, conn) do
    conn
    |> put_flash(:error, "All fields required")
    |> redirect(to: Routes.sell_path(conn, :new))
  end
end
