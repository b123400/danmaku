defmodule DanmakuApi.Repo.Migrations.CreateComment do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :source, :string
      add :anilist_id, :integer
      add :episode, :string
      add :text, :string
      add :metadata, :string

      timestamps
    end

  end
end
