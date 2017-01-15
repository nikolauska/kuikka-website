defmodule KuikkaDB.Schema.Category do
  @moduledoc """
  Database schema for category table
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "category" do
    field :name, :string
    field :description, :string
    has_many :topics, KuikkaDB.Schema.Topic
  end

  @required [:name]
  @optional [:description]

  @doc """
  Validate changes to tag
  """
  @spec changeset(Ecto.Schema.t, Map.t) :: Ecto.Changeset.t
  def changeset(category, params) when is_map(params) do
    category
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
  end
end
