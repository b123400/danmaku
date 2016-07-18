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
    plug CORSPlug, [origin: "https://anime.soruly.hk"]
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
    options "/articles", CommentController, :options
    get  "/comments/add", CommentController, :create
    post "/comments/add", CommentController, :create

    get "/episode", EpisodeController, :show
    post "/episode", EpisodeController, :update
  end
end
