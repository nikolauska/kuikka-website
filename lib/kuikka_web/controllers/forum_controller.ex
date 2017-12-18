defmodule KuikkaWeb.ForumController do
  use KuikkaWeb, :controller

  alias KuikkaWeb.Endpoint
  alias Kuikka.Forum

  # Check that user is logged in
  plug :require_user, [] when action in [:new, :edit, :create, :update]

  # Check that id is integer
  plug :param_check, [type: :integer, to: forum_path(Endpoint, :topics)]
    when action in [:topic, :update]

  @spec topics(Plug.Conn.t, map) :: Plug.Conn.t
  def topics(conn, _params) do
    render conn, "topics.html"
  end

  @spec topic(Plug.Conn.t, map) :: Plug.Conn.t
  def topic(conn, _params) do
    render conn, "topic.html"
  end

  @spec categories(Plug.Conn.t, map) :: Plug.Conn.t
  def categories(conn, _params) do
    render conn, "categories.html"
  end

  @spec category(Plug.Conn.t, map) :: Plug.Conn.t
  def category(conn, _params) do
    render conn, "category.html"
  end

  @spec new_topic(Plug.Conn.t, map) :: Plug.Conn.t
  def new_topic(conn, _params) do
    conn
    |> assign(:changeset, Forum.topic_changeset())
    |> render("new_topic")
  end

  @spec edit_topic(Plug.Conn.t, map) :: Plug.Conn.t
  def edit_topic(conn, _params) do
    render conn, "topic.html"
  end

  @spec create(Plug.Conn.t, map) :: Plug.Conn.t
  def create(conn, %{"topic" => params}) do
    case Forum.create_topic(params) do
      {:ok, topic} ->
        redirect(conn, to: forum_path(conn, :topic, topic.id))

      {:error, changeset} ->
        conn
        |> assign(:changeset, changeset)
        |> render("new_topic.html")
    end
  end

  @spec update(Plug.Conn.t, map) :: Plug.Conn.t
  def update(conn, %{"id" => topic, "topic" => params}) do
    case Forum.update_topic(topic, params) do
      {:ok, topic} ->
        redirect(conn, to: forum_path(conn, :topic, topic.id))

      {:error, err} when is_binary(err) ->
        redirect(conn, to: forum_path(conn, :topics))

      {:error, changeset} ->
        conn
        |> assign(:changeset, changeset)
        |> render("new_topic.html")
    end
  end
end
