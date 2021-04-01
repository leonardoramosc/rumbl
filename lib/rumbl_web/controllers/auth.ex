defmodule Rumbl.Auth do
  import Plug.Conn

  def init(opts) do
    # Si en opts no esta presente un :repo, lanzar error
    # esto es para establecer que el repo es requerido
    # para poder usar este plug.
    Keyword.fetch!(opts, :repo)
  end

  # Call recibe el repo porque se lo estoy pasando con la funcion init
  #(keyword.fetch retorna el valor de la key solicitada).
  def call(conn, repo) do
    user_id = get_session(conn, :user_id)
    # si hay un usuario con sesion iniciada, obtener ese usuario de la DB
    # (al iniciar sesion, el id del usuario se guarda en la sesion)
    user = user_id && repo.get(Rumbl.User, user_id)
    # assign asigna al objeto conn.assigns la llave y el valor especificados
    # de esta forma, el usuario obtenido de la DB estara presente en conn.assigns
    # en toda la app y podra ser usado en todas las vistas y controladores.
    assign(conn, :current_user, user)
  end

  def login(conn, user) do
    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end
end
