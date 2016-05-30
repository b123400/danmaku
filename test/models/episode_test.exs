defmodule DanmakuApi.EpisodeTest do
  use DanmakuApi.ModelCase

  alias DanmakuApi.Episode

  @valid_attrs %{anilist_id: 42, episode: "some content", source: "some content", source_id: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Episode.changeset(%Episode{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Episode.changeset(%Episode{}, @invalid_attrs)
    refute changeset.valid?
  end
end
