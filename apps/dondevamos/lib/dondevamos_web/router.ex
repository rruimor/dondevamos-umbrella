defmodule DondevamosWeb.Router do
  use DondevamosWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug DondevamosWeb.Plugs.SetUser
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug DondevamosWeb.Plugs.RequireAuth
  end

  scope "/auth", DondevamosWeb do
    pipe_through :browser

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    post "/:provider/callback", AuthController, :callback
    delete "/logout", AuthController, :delete
  end

  scope "/yolo", DondevamosWeb do
    pipe_through [:browser, :auth]

    get "/", PageController, :yolo
  end

  scope "/", DondevamosWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", DondevamosWeb do
  #   pipe_through :api
  # end
end
