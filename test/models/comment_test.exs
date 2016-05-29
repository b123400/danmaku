defmodule DanmakuApi.CommentTest do
  use DanmakuApi.ModelCase

  alias DanmakuApi.Comment

  @valid_attrs %{anilist_id: 42, episode: "some content", metadata: "some content", source: "some content", text: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Comment.changeset(%Comment{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Comment.changeset(%Comment{}, @invalid_attrs)
    refute changeset.valid?
  end
end
