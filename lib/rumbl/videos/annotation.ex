defmodule Rumbl.Videos.Annotation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "video_annotations" do
    field :at, :integer
    field :body, :string

    belongs_to :user, Rumbl.Users.User
    belongs_to :video, Rumbl.Videos.Video

    timestamps()
  end

  @doc false
  def changeset(annotation, attrs) do
    annotation
    |> cast(attrs, [:body, :at])
    |> validate_required([:body, :at])
  end
end
