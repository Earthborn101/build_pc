defmodule BuildPcWeb.Router do
  use BuildPcWeb, :router

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

  scope "/api", Api do
    pipe_through :api
    scope "/v1", V1 do
      scope "/parts" do
        post "/search-parts", PartsController, :search_parts 
      end
    end
  end

  scope "/", BuildPcWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", BuildPcWeb do
  #   pipe_through :api
  # end
end
