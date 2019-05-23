defmodule EbaeWeb.LayoutView do
  use EbaeWeb, :view

  alias EbaeWeb.Auth

  def authenticated?(conn) do
    Auth.authenticated?(conn)
  end
end
