defmodule Kuikka.Forum do
  @moduledoc """
  Main module for managing forums
  """

  alias Kuikka.Repo
  alias Kuikka.Forum.Topic
  #alias Kuikka.Forum.Comment
  #alias Kuikka.Forum.Category

  @doc """
  Create new topic from params

  ## Example
  ```
  Forum.create_topic(%{title: "test", content: "test", member_id: 1})
  ```
  """
  @spec create_topic(map) :: {:ok, Topic.t} | {:error, Ecto.Changeset.t}
  def create_topic(params) do
    %Topic{}
    |> Topic.changeset(params)
    |> Repo.insert()
  end

  @doc """
  Update topic with struct, id or search list

  ## Example
  ```
  Forum.update_topic(%Topic{}, %{title: "test"})
  Forum.update_topic(1, %{title: "test"})
  Forum.update_topic([title: "not test"], %{title: "test"})
  ```
  """
  @spec update_topic(Topic.t | integer | list | nil, map) ::
                                        {:ok, Topic.t} |
                                        {:error, Ecto.Changeset.t | String.t}
  def update_topic(nil, _params) do
    {:error, "topic not found"}
  end
  def update_topic(topic = %Topic{}, params) do
    topic
    |> Topic.changeset(params)
    |> Repo.update()
  end
  def update_topic(topic, params) when is_integer(topic) do
    Topic
    |> Repo.get(topic)
    |> update_topic(params)
  end
  def update_topic(topic, params) when is_list(topic) do
    Topic
    |> Repo.get_by(topic)
    |> update_topic(params)
  end

  @doc """
  Generate empty changeset for topic
  """
  @spec topic_changeset() :: Ecto.Changeset.t
  def topic_changeset do
    Topic.changeset(%Topic{}, %{})
  end
end
