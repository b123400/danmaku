defmodule DanmakuApi.EpisodeController do
  use DanmakuApi.Web, :controller

  alias DanmakuApi.Episode

  plug :scrub_params, "episode" when action in [:create, :update]

  # def create(conn, %{"episode" => episode_params}) do
  #   changeset = Episode.changeset(%Episode{}, episode_params)

  #   case Repo.insert(changeset) do
  #     {:ok, episode} ->
  #       conn
  #       |> put_status(:created)
  #       |> put_resp_header("location", episode_path(conn, :show, episode))
  #       |> render("show.json", episode: episode)
  #     {:error, changeset} ->
  #       conn
  #       |> put_status(:unprocessable_entity)
  #       |> render(DanmakuApi.ChangesetView, "error.json", changeset: changeset)
  #   end
  # end

  def show(conn, %{"source" => source, "anilist_id" => anilist_id} = params) do
    filename = params["filename"]
    source_id = params["source_id"]

    db_episode = Repo.get_by(Episode, %{
      "source": source,
      "source_id": source_id || filename,
      "anilist_id": anilist_id
    })
    {episode_source, episode} = case db_episode do
      nil -> case :episode_guesser.guess(filename, anilist_id) do
        {:found, num} -> {:detected, to_string num}
        :notfound -> {:failed, source_id || filename}
      end
      a -> {:user_provided, a.episode}
    end
    json conn, %{
      "episode_source": Atom.to_string(episode_source),
      "episode": episode
    }
    # render(conn, "show.json", episode: episode)
  end

  def update(conn, %{"source" => source, "anilist_id" => anilist_id, "episode" => episode} = params) do

    filename = params["filename"]
    source_id = params["source_id"]

    db_episode = Repo.get_by(Episode, %{
      "source": source,
      "source_id": source_id || filename,
      "anilist_id": anilist_id
    })

    modification = case db_episode do
      nil ->
        changeset = Episode.changeset(%Episode{}, %{
          "source": source,
          "source_id": source_id || filename,
          "anilist_id": anilist_id,
          "episode": episode
          })
        Repo.insert(changeset)

      _ ->
        changeset = Episode.changeset(db_episode, %{ "episode": episode })
        Repo.update(changeset)
    end

    case modification do
      {:ok, episode} ->
        json conn, episode
      {:error, changeset} ->
        errors = changeset.errors
        |> Enum.into(%{})
        json conn, %{error: errors}
    end
  end

  # def delete(conn, %{"id" => id}) do
  #   episode = Repo.get!(Episode, id)

  #   # Here we use delete! (with a bang) because we expect
  #   # it to always work (and if it does not, it will raise).
  #   Repo.delete!(episode)

  #   send_resp(conn, :no_content, "")
  # end
end
