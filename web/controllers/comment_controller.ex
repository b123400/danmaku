require IEx;

defmodule DanmakuApi.CommentController do
  use DanmakuApi.Web, :controller

  alias DanmakuApi.Comment

  def index(conn, params) do
    source = params["source"]
    anilist_id = params["anilist_id"]
    param_episode = params["episode"]
    filename = params["filename"]

    if anilist_id == nil || (param_episode == nil && filename == nil) do
      conn
      |> put_status(400)
      |> json %{"error": "Missing param? I need `anilist_id` and (`episode` or `filename`)"}
    end

    {episode_source, episode} = case param_episode do
      nil -> guess_episode(filename, anilist_id)
      a -> {:given, a}
    end

    comments = Repo.all(Comment)
    json conn, %{
      "episode_source": Atom.to_string(episode_source),
      "episode": episode,
      "comments": comments
    }
  end

  def guess_episode(filename, anilist_id) do
    case :episode_guesser.guess(filename, anilist_id) do
      :notfound -> {:failed, filename}
      {:found, episode} -> {:detected, episode}
    end
    # or {:provided, ""} if present from db
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