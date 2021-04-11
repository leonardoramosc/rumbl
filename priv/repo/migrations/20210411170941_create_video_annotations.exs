defmodule Rumbl.Repo.Migrations.CreateVideoAnnotations do
  use Ecto.Migration

  def change do
    create table(:video_annotations) do
      add :body, :text
      add :at, :integer
      add :user_id, references(:users, on_delete: :nothing)
      add :video_id, references(:videos, on_delete: :nothing)

      timestamps()
    end

    create index(:video_annotations, [:user_id])
    create index(:video_annotations, [:video_id])
  end
end
