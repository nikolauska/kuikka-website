defmodule Frontend.Page.EventController do
  use Frontend.Web, :controller
  plug :put_layout, "base.html"

  alias KuikkaDB.Comments
  alias KuikkaDB.EventComments
  alias KuikkaDB.Events
  alias Steamex.Profile
  alias Frontend.Utils

  @doc """
  Show event list or editor to create new event
  """
  @spec index(Plug.Conn.t, Map.t) :: Plug.Conn.t
  def index(conn, %{"editor" => "true"}) do
    if Utils.has_permission?(conn, "create_event") do
      conn
      |> assign(:type, :create)
      |> assign(:event, nil)
      |> assign(:title, "")
      |> assign(:time, Timex.now())
      |> assign(:content, "")
      |> render("editor.html")
    else
      conn
      |> put_flash(:error, dgettext("event",
                                "You don't have the permission to create events"))
      |> redirect(to: home_path(conn, :index))
    end
  end
  def index(conn, _params) do
    if Utils.has_permission?(conn, "read_event") do
      case Events.event_list() do
        {:ok, events} ->
          conn
          |> assign(:events, events)
          |> render("event_list.html")
          {:error, _} ->
            conn
            |> put_flash(:error, dgettext("event", "Failed to load event list"))
            |> redirect(to: home_path(conn, :index))
      end
    else
      conn
      |> put_flash(:error, dgettext("event", "You don't have permission to see events"))
      |> redirect(to: home_path(conn, :index))
    end
  end

  @doc """
  Show event or update old event in editor
  """
  @spec show(Plug.Conn.t, Map.t) :: Plug.Conn.t
  def show(conn, %{"id" => event, "editor" => "true"}) do
      if Utils.has_permission?(conn, "create_event") do
        with {eventid, ""} <- Integer.parse(event),
            {:ok, [event]} <- Events.get(id: eventid)
            do
              conn
              |> assign(:type, :update)
              |> assign(:event, eventid)
              |> assign(:title, event.title)
              |> assign(:content, event.content)
              |> assign(:time, event.date)
              |> render("editor.html")
            else
              _ ->
                conn
                |> redirect(to: event_path(conn, :index))
                |> put_flash(:error, dgettext("event", "Failed to load editor"))
       end
     else
       conn
       |> put_flash(:error, dgettext("event", "You don't have permission to create events"))
       |> redirect(to: home_path(conn, :index))
      end
     end
  def show(conn, %{"id" => event}) do
    if Utils.has_permission?(conn, "read_event") do
      with {event, ""} <- Integer.parse(event),
          {:ok, [event]} <- Events.get(id: event),
          {:ok, comments} <- Comments.event_comments(event.id)
      do
        conn
        |> assign(:event, event)
        |> assign(:comments, Enum.map(comments, &profile_to_user(&1)))
        |> render("event.html")
      else
        {:error, msg} when is_binary(msg) ->
          conn
          |> put_flash(:error, msg)
          |> redirect(to: event_path(conn, :index))
          _ ->
            conn
            |> put_flash(:error, dgettext("event", "Invalid event url"))
            |> redirect(to: event_path(conn, :index))
    end
  else
    conn
    |> put_flash(:error, dgettext("event", "You don't have permission to see events"))
    |> redirect(to: home_path(conn, :index))
  end
end
  @doc """
  Create or update event page
  """
  @spec create(Plug.Conn.t, Map.t) :: Plug.Conn.t
  def create(conn, %{"event" => %{"title" => title,
                                  "text" => text,
                                  "event" => event,
                                  "time" => time}}) do
    if Utils.has_permission?(conn, "create_event") do
      time = to_datetime(time)
      with {event, ""} <- Integer.parse(event),
          {:ok, _} <- Events.update([title: title, content: text, date: time],
                                    [id: event])
                                    do
         conn
         |> put_flash(:info, dgettext("event", "Event updated"))
         |> redirect(to: event_path(conn, :show, event))
       else
         _ ->
           conn
           |> put_flash(:error, dgettext("event", "Failed to update event"))
           |> redirect(to: event_path(conn, :show, event, %{"editor" => "true"}))
         end
    else
      conn
      |> put_flash(:error, dgettext("event", "You don't have rights to update events"))
      |> redirect(to: home_path(conn, :index))
   end
  end
  def create(conn, %{"event" => %{"title" => title, "time" => time,
                                  "text" => text}}) do
    if Utils.has_permission?(conn, "create_event") do
      time = to_datetime(time)

      with {:ok, [%{id: e_id}]} <- Events.insert(title: title, content: text,
                                              date: time)
      do
        conn
        |> put_flash(:info, dgettext("event", "New event created"))
        |> redirect(to: event_path(conn, :show, e_id))
      else
        _ ->
          conn
          |> put_flash(:error, dgettext("event", "Failed create event"))
          |> redirect(to: event_path(conn, :index, %{"editor" => "true"}))
      end
   else
     conn
     |> put_flash(:error, dgettext("event", "you don't have permission to create events"))
     |> redirect(to: home_path(conn, :index))
   end
  end
  def create(conn, %{"comment" => %{"event" => event,
                                    "text" => text}}) do
    if Utils.has_permission?(conn, "create_event_comment") do
      u_id = conn.assigns.user.id

      with {event, ""} <- Integer.parse(event),
          {:ok, [%{id: c_id}]} <- Comments.insert(text: text, user_id: u_id),
          {:ok, _} <- EventComments.insert(event_id: event, comment_id: c_id)
      do
        conn
        |> put_flash(:info, dgettext("event", "Comment added succesfully"))
        |> redirect(to: event_path(conn, :show, event))
      else
        _ ->
          conn
          |> put_flash(:error, dgettext("event", "Failed to add comment"))
          |> redirect(to: event_path(conn, :show, event))
        end
      else
        conn
        |> put_flash(:error, dgettext("event", "You don't have permission to comment events"))
        |> redirect(to: home_path(conn, :index))
  end
end

  @spec profile_to_user(Map.t) :: Map.t
  defp profile_to_user(map) do
    steamid = Decimal.to_integer(Map.get(map, :user))
    Map.put(map, :profile, Profile.fetch(steamid))
  end

  @spec to_datetime(Map.t) :: DateTime.t
  def to_datetime(%{"year" => y, "month" => m, "day" => d,
                    "hour" => h, "minute" => min}) do
    Timex.to_datetime(%{year: y, month: m, day: d, hour: h, minute: min})
  end
end
