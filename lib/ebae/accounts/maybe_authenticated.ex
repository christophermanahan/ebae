defmodule Ebae.Accounts.MaybeAuthenticated do
  use Guardian.Plug.Pipeline,
    otp_app: :ebae,
    error_handler: Ebae.Accounts.ErrorHandler,
    module: Ebae.Accounts.Guardian

  plug Guardian.Plug.VerifySession, claims: %{"typ" => "access"}
  plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}
  plug Guardian.Plug.LoadResource, allow_blank: true
end
