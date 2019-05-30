defmodule EbaeWeb.SellView do
  use EbaeWeb, :view

  alias EbaeWeb.Auth
  alias Ebae.Auction

  def username(conn) do
    Auth.current_user(conn).username
  end

  def items(conn) do
    Auth.current_user(conn)
    |> Auction.get_items!()
  end
end
