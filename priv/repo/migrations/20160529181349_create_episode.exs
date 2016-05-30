defmodule DanmakuApi.Repo.Migrations.CreateEpisode do
  use Ecto.Migration

  def change do
    create table(:episodes) do
      add :source, :string
      add :source_id, :string
      add :anilist_id, :integer
      add :episode, :string

      timestamps
    end

  end
end
