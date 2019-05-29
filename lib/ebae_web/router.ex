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

    get "/signin", SessionController, :new
    post "/signin", SessionController, :create

    delete "/signout", SessionController, :delete

    get "/signup", RegistrationController, :new
    post "/signup", RegistrationController, :create
  end

  scope "/sell", EbaeWeb do
    pipe_through [:browser, :auth, :ensure_auth]

    get "/", SellController, :index

    get "/new", SellController, :new

    post "/create", SellController, :create
  end
end
