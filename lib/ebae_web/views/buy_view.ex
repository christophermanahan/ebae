defmodule EbaeWeb.BuyView do
  use EbaeWeb, :view

  alias EbaeWeb.Auth
  alias Ebae.Auction

  def username(conn) do
    Auth.current_user(conn).username
  end

  def items(conn) do
    conn
    |> Auth.current_user
    |> Auction.get_buyers_items!
  end
end
