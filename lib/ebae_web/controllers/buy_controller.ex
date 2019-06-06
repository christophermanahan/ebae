defmodule EbaeWeb.BuyController do
  use EbaeWeb, :controller

  alias Ebae.{Auctions, Auctions.Bid}
  alias EbaeWeb.Auth

  def buy(conn, params) do
    render(conn, "buy.html", datetime: Map.get(params, "datetime", DateTime))
  end

  def bids(conn, _) do
    render(conn, "bids.html")
  end

  def won(conn, params) do
    render(conn, "won.html", datetime: Map.get(params, "datetime", DateTime))
  end

  def new(conn, %{"id" => auction_id}) do
    render(conn, "new.html",
      changeset: Auctions.change_bid(%Bid{}),
      action: Routes.buy_path(conn, :create, auction_id)
    )
  end

  def create(conn, %{"bid" => bid, "id" => auction_id}) do
    conn
    |> validate_and_create(bid, auction_id)
    |> create_reply(conn, auction_id)
  end

  defp validate_and_create(conn, bid, auction_id) do
    if validate(bid) do
      user_id = Map.get(Auth.current_user(conn), :id)
      with_associations = Map.merge(bid, %{"user_id" => user_id, "auction_id" => auction_id})
      Auctions.create_bid(with_associations)
    else
      :error
    end
  end

  defp validate(%{"offer" => offer}) do
    offer != nil
  end

  defp create_reply({:ok, _}, conn, _) do
    conn
    |> put_flash(:info, "Bid successfully offered")
    |> redirect(to: Routes.buy_path(conn, :buy))
  end

  defp create_reply({:error, _}, conn, auction_id) do
    conn
    |> put_flash(:error, "Form submission invalid")
    |> redirect(to: Routes.buy_path(conn, :new, auction_id))
  end

  defp create_reply(:error, conn, auction_id) do
    conn
    |> put_flash(:error, "All fields required")
    |> redirect(to: Routes.buy_path(conn, :new, auction_id))
  end
end
