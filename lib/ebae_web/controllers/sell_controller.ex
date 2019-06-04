defmodule EbaeWeb.SellController do
  use EbaeWeb, :controller

  alias Ebae.{Auctions, Auctions.Auction}
  alias EbaeWeb.Auth

  def new(conn, _) do
    render(conn, "new.html",
      changeset: Auctions.change_auction(%Auction{}),
      action: Routes.sell_path(conn, :create)
    )
  end

  def index(conn, _) do
    render(conn, "index.html")
  end

  def delete(conn, %{"id" => id}) do
    Auctions.get_auction!(id)
    |> Auctions.delete_auction
    |> delete_reply(conn)
  end

  defp delete_reply({:ok, _}, conn) do
    conn
    |> put_flash(:info, "Listing successfully deleted")
    |> redirect(to: Routes.sell_path(conn, :index))
  end

  def create(conn, %{"auction" => auction}) do
    conn
    |> validate_and_create(auction)
    |> create_reply(conn)
  end

  defp validate_and_create(conn, auction) do
    if (validate(auction)) do
      user_id = Map.get(Auth.current_user(conn), :id)
      with_associations = Map.put(auction, "user_id", user_id)
      Auctions.create_auction(with_associations)
    else
      :error
    end
  end

  defp validate(auction) do
    Map.values(auction)
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
