defmodule RumblWeb.UserView do
  use RumblWeb, :view
  alias Rumbl.Users.User

  def first_name(%User{name: name}) do
    name
    |> String.split(" ")
    |> Enum.at(0)
  end
end
