require IEx;

defmodule DanmakuApi.CommentController do
  use DanmakuApi.Web, :controller

  alias DanmakuApi.Comment

  def index(conn, _params) do
    comments = Repo.all(Comment)
    IEx.pry
    json conn, comments
  end
end