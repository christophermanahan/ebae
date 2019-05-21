defmodule EbaeWeb.LayoutView do
  use EbaeWeb, :view

  alias Ebae.Accounts.Guardian

  def signed_in?(conn) do
    Guardian.Plug.authenticated?(conn)
  end
end
