defmodule DanmakuApi.Repo.Migrations.AddTimeToComment do
  use Ecto.Migration

  def change do
    alter table(:comments) do
      add :time, :integer
    end
  end
end
