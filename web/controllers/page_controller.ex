defmodule DanmakuApi.PageController do
  use DanmakuApi.Web, :controller

  def index(conn, _params) do
    conn
    |> put_layout(false)
    |> render "test.html"
  end
end
