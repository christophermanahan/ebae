defmodule Ebae.EmailWorker do
  alias Ebae.{Auctions, Email, Mailer}

  def perform(auction_id) do
    with {:ok, auction} <- Auctions.get_auction!(auction_id),
         {:ok, winner} <- Auctions.highest_bidder(auction_id) do
      winner
      |> Email.won_email(auction.name)
      |> Mailer.deliver_now()
    else
      _err -> :no_winner
    end
  end
end
