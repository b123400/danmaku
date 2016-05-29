defmodule DanmakuApi.PageController do
  use DanmakuApi.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
