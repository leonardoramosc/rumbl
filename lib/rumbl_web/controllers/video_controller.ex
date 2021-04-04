defmodule RumblWeb.VideoController do
  use RumblWeb, :controller

  alias Rumbl.Videos
  alias Rumbl.Videos.Category
  # alias Rumbl.Videos.Video
  alias RumblWeb.Router.Helpers

  plug :load_categories when action in [:new, :create, :edit, :delete]

  def index(conn, _params, user) do
    videos = Videos.list_user_videos(user)
    render(conn, "index.html", videos: videos)
  end

  def new(conn, _params, user) do
    changeset = Videos.create_changeset(user)
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"video" => video_params}, user) do

    case Videos.create_video(user, video_params) do
      {:ok, video} ->
        conn
        |> put_flash(:info, "Video created successfully.")
        |> redirect(to: Helpers.video_path(conn, :show, video))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, user) do
    video = Videos.get_user_video!(user, id)
    render(conn, "show.html", video: video)
  end

  def edit(conn, %{"id" => id}, user) do
    video = Videos.get_user_video!(user, id)
    changeset = Videos.change_video(video)
    render(conn, "edit.html", video: video, changeset: changeset)
  end

  def update(conn, %{"id" => id, "video" => video_params}, user) do
    video = Videos.get_user_video!(user, id)

    case Videos.update_video(video, video_params) do
      {:ok, video} ->
        conn
        |> put_flash(:info, "Video updated successfully.")
        |> redirect(to: Helpers.video_path(conn, :show, video))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", video: video, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, user) do
    video = Videos.get_user_video!(user, id)
    {:ok, _video} = Videos.delete_video(video)

    conn
    |> put_flash(:info, "Video deleted successfully.")
    |> redirect(to: Helpers.video_path(conn, :index))
  end

  def action(conn, _) do
    apply(__MODULE__, action_name(conn),
      [conn, conn.params, conn.assigns.current_user])
  end

  defp load_categories(conn, _) do
    query =
      Category
      |> Videos.categories_alphabetical
      |> Videos.categories_names_and_ids

    categories = Videos.list_categories(query)

    assign(conn, :categories, categories)
  end

end
