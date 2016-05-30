defmodule DanmakuApi.Episode do
  use DanmakuApi.Web, :model

  schema "episodes" do
    field :source, :string
    field :source_id, :string
    field :anilist_id, :integer
    field :episode, :string

    timestamps
  end

  @required_fields ~w(source source_id anilist_id episode)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
