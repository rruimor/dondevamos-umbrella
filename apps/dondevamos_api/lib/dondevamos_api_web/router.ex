defmodule DondevamosApiWeb.Router do
  use DondevamosApiWeb, :router

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

  scope "/", DondevamosApiWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

   scope "/api", DondevamosApiWeb do
     pipe_through :api

     get "/flights", FlightsController, :flights
   end
end
