defmodule Rumbl.Users.User do
  use Ecto.Schema
  import Ecto.Changeset
  # import Comeonin

  schema "users" do
    field :name, :string
    field :username, :string
    field :password, :string, virtual: true
    field :password_hash, :string

    has_many :videos, Rumbl.Videos.Video

    timestamps()
  end

  @doc false
  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [:name, :username])
    |> validate_length(:username, min: 1, max: 20)
    |> unique_constraint(:username)
  end

    # este changeset sirve para aplicr validacion al username haciendo uso de la funcion changeset
  # ademas, esta funcion agrega un :password_hash al changeset, el cual es una contrseña encriptada
  def registration_changeset(user, params) do
    user
    |> changeset(params)
    |> cast(params, [:password], [])
    |> validate_length(:password, min: 6, max: 100)
    |> put_pass_hash()
  end

  def put_pass_hash(changeset) do
    case changeset do
      #Si el changeset es valido, hacer pattern matching para obtener la contraseña
      # luego devolver un changeset con un campo :password_hash el cual contiene la
      # contraseña encriptada
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))
      # Si no es valido, devolver el que se recibio.
      _ ->
        changeset
    end
  end
end
