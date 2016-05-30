defmodule DanmakuApi.Router do
  use DanmakuApi.Web, :router

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

  scope "/", DanmakuApi do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  scope "/api", DanmakuApi do
    pipe_through :api

    get  "/comments", CommentController, :index
    get  "/comments/add", CommentController, :create
    post "/comments/add", CommentController, :create

    post "/episodes", EpisodeController, :update
  end
end
