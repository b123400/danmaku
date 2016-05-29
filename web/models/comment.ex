defmodule DanmakuApi.Comment do
  use DanmakuApi.Web, :model

  @derive {Poison.Encoder, except: [:__meta__]}
  schema "comments" do
    field :source, :string
    field :anilist_id, :integer
    field :episode, :string
    field :text, :string
    field :metadata, :string

    timestamps
  end

  @required_fields ~w(source anilist_id episode text metadata)
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
