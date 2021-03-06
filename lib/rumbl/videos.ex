defmodule Rumbl.Videos do
  @moduledoc """
  The Videos context.
  """

  import Ecto.Query, warn: false
  alias Rumbl.Repo

  alias Rumbl.Videos.Video
  alias Rumbl.Videos.Category
  alias Rumbl.Videos.Annotation
  alias Rumbl.Users.User

  @doc """
  Returns the list of videos.

  ## Examples

      iex> list_videos()
      [%Video{}, ...]

  """
  def list_videos do
    Repo.all(Video)
  end

  @doc """
  Gets a single video.

  Raises `Ecto.NoResultsError` if the Video does not exist.

  ## Examples

      iex> get_video!(123)
      %Video{}

      iex> get_video!(456)
      ** (Ecto.NoResultsError)

  """
  def get_video!(id), do: Repo.get!(Video, id)

  @doc """
  Creates a video.

  ## Examples

      iex> create_video(%{field: value})
      {:ok, %Video{}}

      iex> create_video(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_video(user, attrs \\ %{}) do
    user
    |> Ecto.build_assoc(:videos)
    |> Video.changeset(attrs)
    |> Repo.insert()

    # %Video{}
    # |> Video.changeset(attrs)
    # |> Repo.insert()
  end

  @doc """
  Updates a video.

  ## Examples

      iex> update_video(video, %{field: new_value})
      {:ok, %Video{}}

      iex> update_video(video, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_video(%Video{} = video, attrs) do
    video
    |> Video.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a video.

  ## Examples

      iex> delete_video(video)
      {:ok, %Video{}}

      iex> delete_video(video)
      {:error, %Ecto.Changeset{}}

  """
  def delete_video(%Video{} = video) do
    Repo.delete(video)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking video changes.

  ## Examples

      iex> change_video(video)
      %Ecto.Changeset{data: %Video{}}

  """
  def change_video(%Video{} = video, attrs \\ %{}) do
    Video.changeset(video, attrs)
  end

  def create_changeset(user, attrs \\ %{}) do
    user
    |> Ecto.build_assoc(:videos)
    |> Video.changeset(attrs)
  end

  def user_videos(user), do: Ecto.assoc(user, :videos)

  def list_user_videos(%User{} = user), do: Repo.all(user_videos(user))

  def get_user_video!(user, video_id), do: Repo.get!(user_videos(user), video_id)

  # CATEGORIES
  def categories_alphabetical(query) do
    from c in query, order_by: c.name
  end

  def categories_names_and_ids(query) do
    from c in query, select: {c.name, c.id}
  end

  def list_categories(query) do
    Repo.all(query)
  end

  #################################################################################################### 3
  # ANNOTATIONS
  #################################################################################################### 3
  def create_annotation_changeset(%User{} = user, socket, params) do
    user
    |> Ecto.build_assoc(:annotations, video_id: socket.assigns.video_id)
    |> Annotation.changeset(params)
  end

  def create_annotation(changeset) do
    Repo.insert(changeset)
  end

  def list_annotations_of_video(video, limit, last_seen_id) do
    Repo.all(
      from a in Ecto.assoc(video, :annotations),
      order_by: [asc: a.at, asc: a.id],
      limit: ^limit,
      # Obtener todas las anotaciones cuyo id este despues del last_seen_id
      # para evitar enviar al cliente las anotaciones que ya esten renderizadas.
      where: a.id > ^last_seen_id,
      preload: [:user]
    )
  end
end
