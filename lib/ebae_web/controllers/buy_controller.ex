defmodule EbaeWeb.BuyController do
  use EbaeWeb, :controller

  def index(conn, _) do
    render(conn, "index.html")
  end
end
