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
end