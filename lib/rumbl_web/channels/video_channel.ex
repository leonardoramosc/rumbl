defmodule RumblWeb.VideoChannel do
  use RumblWeb, :channel

  alias Rumbl.Videos
  alias Rumbl.Users

  def join("videos:" <> video_id, _params, socket) do
    {:ok, assign(socket, :video_id, String.to_integer(video_id))}
  end

  def handle_in(event, params, socket) do
    user = Users.get_user!(socket.assigns.user_id)
    handle_in(event, params, user, socket)
  end

  # esta funcion maneja los mensajes entrantes a este canal.
  def handle_in("new_annotation", params, user, socket) do
    changeset = Videos.create_annotation_changeset(user, socket, params)

    case Videos.create_annotation(changeset) do
      {:ok, annotation} ->
        # broadcast envia un evento a todos los usuarios en el topico actual
        broadcast!(socket, "new_annotation", %{
          id: annotation.id,
          user: RumblWeb.UserView.render("user.json", %{user: user}),
          body: annotation.body,
          at: annotation.at
        })
        {:reply, :ok, socket}
      {:error, changeset} ->
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end

  # def handle_info(:ping, socket) do
  #   count = socket.assigns[:count] || 0
  #   push socket, "ping", %{count: count}

  #   {:noreply, assign(socket, :count, count + 1)}
  # end
end
