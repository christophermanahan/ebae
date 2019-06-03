defmodule EbaeWeb.BuyView do
  use EbaeWeb, :view

  alias EbaeWeb.Auth
  alias Ebae.Auctions

  def username(conn) do
    Auth.current_user(conn).username
  end

  def auctions(conn) do
    conn
    |> Auth.current_user
    |> Auctions.get_buyers_auctions!
  end

  def current_price(%{:bids => []} = auction) do
    auction.initial_price
  end

  def current_price(auction) do
    auction.bids
    |> Enum.map(fn bid -> bid.offer end)
    |> Enum.max
  end
end
