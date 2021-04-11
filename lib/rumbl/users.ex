defmodule Rumbl.Users do
  import Ecto.Query, warn: false
  alias Rumbl.Repo
  alias Rumbl.Users.User

  def get_user!(id), do: Repo.get!(User, id)
end
