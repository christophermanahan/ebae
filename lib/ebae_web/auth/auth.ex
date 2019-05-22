defmodule EbaeWeb.Auth do
  alias Ebae.Accounts.Guardian

  defdelegate authenticated?(conn), to: Guardian.Plug, as: :authenticated?
  defdelegate sign_in(conn, user), to: Guardian.Plug, as: :sign_in
  defdelegate sign_out(conn), to: Guardian.Plug, as: :sign_out
end
