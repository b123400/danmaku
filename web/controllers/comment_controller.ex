require IEx;

defmodule DanmakuApi.CommentController do
  use DanmakuApi.Web, :controller

  alias DanmakuApi.Comment
  alias DanmakuApi.Episode

  def index(conn, params) do
    source = params["source"]
    anilist_id = params["anilist_id"]
    param_episode = params["episode"]
    filename = params["filename"]

    if anilist_id == nil || (param_episode == nil && filename == nil) do
      conn
      |> put_status(400)
      |> json(%{"error": "Missing param? I need `anilist_id` and (`episode` or `filename`)"})
    else

      {episode_source, episode} = case param_episode do
        nil -> guess_episode(source, filename, anilist_id)
        a -> {:given, a}
      end

      query = Ecto.Query.from c in Comment,
        where: c.anilist_id == ^anilist_id and c.episode == ^episode

      if source != "all" do
        query = Ecto.Query.from c in query, where: c.source == ^source
      end

      comments = Repo.all(query)
      json conn, %{
        "episode_source": Atom.to_string(episode_source),
        "episode": episode,
        "comments": comments
      }
    end
  end

  def guess_episode(source, filename, anilist_id) do
    db_episode = Repo.get_by(Episode, %{
      "source": source,
      "source_id": filename,
      "anilist_id": anilist_id
    })
    if db_episode != nil do
      {:user_provided, db_episode.episode}
    else
      case :episode_guesser.guess(filename, anilist_id) do
        :notfound -> {:failed, filename}
        {:found, episode} -> {:detected, to_string episode}
      end
    end
  end

  def create(conn, params) do

    source = "kari"
    anilist_id = params["anilist_id"]
    param_episode = params["episode"]
    filename = params["filename"]
    text = params["text"]
    {time, _} = Integer.parse params["time"]
    IO.inspect "Wwwwwwww"
    IO.inspect time

    if filename == nil && param_episode == nil do
      conn
      |> put_status(400)
      |> json(%{"error": "Missing param? I need `anilist_id` and (`episode` or `filename`)"})
    else

      {episode_source, episode} = case param_episode do
        nil -> guess_episode(source, filename, anilist_id)
        a -> {:given, a}
      end

      changeset = Comment.changeset(%Comment{}, %{
        source: source,
        anilist_id: anilist_id,
        episode: episode,
        text: text,
        time: time,
        metadata: params["metadata"] || "{}"
      })
      case Repo.insert(changeset) do
        {:ok, comment} ->
          json conn, %{
            "episode_source": Atom.to_string(episode_source),
            "episode": episode,
            "comment": comment
          }
        {:error, changeset} ->
          errors = changeset.errors
          |> Enum.into(%{})
          json conn, %{error: errors}
      end
    end
  end
end
