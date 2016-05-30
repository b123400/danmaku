defmodule DanmakuApi.EpisodeView do
  use DanmakuApi.Web, :view

  def render("index.json", %{episodes: episodes}) do
    %{data: render_many(episodes, DanmakuApi.EpisodeView, "episode.json")}
  end

  def render("show.json", %{episode: episode}) do
    %{data: render_one(episode, DanmakuApi.EpisodeView, "episode.json")}
  end

  def render("episode.json", %{episode: episode}) do
    %{id: episode.id,
      source: episode.source,
      source_id: episode.source_id,
      anilist_id: episode.anilist_id,
      episode: episode.episode}
  end
end
