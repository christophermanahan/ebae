defmodule EbaeWeb.SellController do
  use EbaeWeb, :controller

  alias Ebae.{Auctions, Auctions.Auction}
  alias EbaeWeb.Auth

  def sell(conn, params) do
    render(conn, "sell.html", datetime: Map.get(params, "datetime", DateTime))
  end

  def sold(conn, params) do
    render(conn, "sold.html", datetime: Map.get(params, "datetime", DateTime))
  end

  def new(conn, _) do
    render(conn, "new.html",
      changeset: Auctions.change_auction(%Auction{}),
      action: Routes.sell_path(conn, :create)
    )
  end

  def auction(conn, %{"id" => auction_id}) do
    conn
    |> validate_and_get(auction_id)
    |> auction_reply(conn)
  end

  defp validate_and_get(conn, auction_id) do
    auction = Auctions.get_auction!(auction_id)

    if validate_owner(auction, conn) do
      auction
    else
      :error
    end
  end

  defp validate_owner(auction, conn) do
    Auth.current_user(conn).id == auction.user_id
  end

  defp auction_reply(%Auction{} = auction, conn) do
    render(conn, "auction.html", auction: auction)
  end

  defp auction_reply(:error, conn) do
    conn
    |> put_flash(:error, "Invalid auction")
    |> redirect(to: Routes.sell_path(conn, :sell))
  end

  def delete(conn, %{"id" => id}) do
    Auctions.get_auction!(id)
    |> Auctions.delete_auction()
    |> delete_reply(conn)
  end

  defp delete_reply({:ok, _}, conn) do
    conn
    |> put_flash(:info, "Listing successfully deleted")
    |> redirect(to: Routes.sell_path(conn, :sell))
  end

  def create(conn, %{"auction" => auction} = params) do
    datetime = Map.get(params, "datetime", DateTime)

    conn
    |> validate_and_create(auction, datetime)
    |> create_reply(conn)
  end

  defp validate_and_create(conn, auction, datetime) do
    if validate(auction) do
      user_id = Map.get(Auth.current_user(conn), :id)

      auction
      |> convert_datetimes
      |> Map.put("user_id", user_id)
      |> Auctions.create_auction(datetime)
    else
      :error
    end
  end

  defp convert_datetimes(auction) do
    auction
    |> Map.update("start", DateTime.utc_now(), fn x -> to_datetime(x) end)
    |> Map.update("finish", DateTime.utc_now(), fn x -> to_datetime(x) end)
  end

  defp to_datetime(%{
         "day" => day,
         "hour" => hour,
         "minute" => minute,
         "month" => month,
         "year" => year
       }) do
    [day, month, hour, minute] = leading_zero_padding([day, month, hour, minute])
    {:ok, datetime, _} = DateTime.from_iso8601("#{year}-#{month}-#{day}T#{hour}:#{minute}:00Z")

    datetime
  end

  defp leading_zero_padding(datetime_strings) do
    datetime_strings
    |> Enum.map(fn x -> to_string(x) end)
    |> Enum.map(fn x -> String.pad_leading(x, 2, "0") end)
  end

  defp validate(auction) do
    Map.values(auction)
    |> Enum.all?(fn key -> key != "" end)
  end

  defp create_reply({:ok, _}, conn) do
    conn
    |> put_flash(:info, "Listing successfully added")
    |> redirect(to: Routes.sell_path(conn, :sell))
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
