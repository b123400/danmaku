require IEx;

defmodule DanmakuApi.CommentController do
  use DanmakuApi.Web, :controller

  alias DanmakuApi.Comment

  def index(conn, _params) do
    comments = Repo.all(Comment)
    json conn, comments
  end

  def create(conn, params) do
    changeset = Comment.changeset(%Comment{}, %{
      source: "kari",
      anilist_id: params["anilist_id"],
      episode: params["episode"],
      text: params["text"],
      metadata: case params["metadata"] do
        nil -> "{}"
        data -> data
      end
    })
    case Repo.insert(changeset) do
      {:ok, comment} ->
        json conn, comment
      {:error, changeset} ->
        errors = changeset.errors
        |> Enum.into(%{})
        json conn, %{error: errors}
    end
  end
end