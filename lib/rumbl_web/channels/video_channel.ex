defmodule RumblWeb.VideoChannel do
  use RumblWeb, :channel

  def join("videos:" <> video_id, _params, socket) do
    {:ok, socket}
  end

  # esta funcion maneja los mensajes entrantes a este canal.
  def handle_in("new_annotation", params, socket) do
    # broadcast envia un evento a todos los usuarios en el topico actual
    broadcast! socket, "new_annotation", %{
      user: %{username: "anon"},
      body: params["body"],
      at: params["at"]
    }

    {:reply, :ok, socket}
  end

  # def handle_info(:ping, socket) do
  #   count = socket.assigns[:count] || 0
  #   push socket, "ping", %{count: count}

  #   {:noreply, assign(socket, :count, count + 1)}
  # end
end
