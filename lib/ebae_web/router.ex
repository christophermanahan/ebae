defmodule EbaeWeb.Router do
  use EbaeWeb, :router

  alias Ebae.Accounts

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug Accounts.MaybeAuthenticated
  end

  pipeline :ensure_auth do
    plug Guardian.Plug.EnsureAuthenticated
  end

  scope "/", EbaeWeb do
    pipe_through [:browser, :auth]

    get "/", PageController, :index

    resources "/signin", SessionController, only: [:new, :create]

    delete "/signout", SessionController, :delete

    resources "/signup", RegistrationController, only: [:new, :create]
  end

  scope "/sell", EbaeWeb do
    pipe_through [:browser, :auth, :ensure_auth]

    get "/", SellController, :sell

    get "/sold", SellController, :sold

    resources "/", SellController, only: [:new, :create, :delete]

    get "/:id", SellController, :auction
  end

  scope "/buy", EbaeWeb do
    pipe_through [:browser, :auth, :ensure_auth]

    get "/", BuyController, :buy

    get "/bids", BuyController, :bids

    get "/won", BuyController, :won

    resources "/:id", BuyController, only: [:new, :create]
  end
end
