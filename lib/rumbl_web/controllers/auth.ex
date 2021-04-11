defmodule RumblWeb.Auth do
  import Plug.Conn
  import Phoenix.Controller
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]

  alias RumblWeb.Router.Helpers

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

    cond do
      user = conn.assigns[:current_user] ->
        put_current_user(conn, user)
      user = user_id && repo.get(Rumbl.Users.User, user_id) ->
        put_current_user(conn, user)
      true ->
        assign(conn, :current_user, nil)
    end
    # si hay un usuario con sesion iniciada, obtener ese usuario de la DB
    # (al iniciar sesion, el id del usuario se guarda en la sesion)

    # assign asigna al objeto conn.assigns la llave y el valor especificados
    # de esta forma, el usuario obtenido de la DB estara presente en conn.assigns
    # en toda la app y podra ser usado en todas las vistas y controladores.
  end

  def login(conn, user) do
    conn
    |> put_current_user(user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end

  def login_by_username_and_pass(conn, user, pass, opts) do
    repo = Keyword.fetch!(opts, :repo)
    user = repo.get_by(Rumbl.Users.User, username: user)

    cond do
      # si el usuario existe y la contraseña es correcta
      user && checkpw(pass, user.password_hash) ->
        {:ok, login(conn, user)}
      # si el usuario existe pero la contraseña no es correcta
      user ->
        {:error, :unauthorized, conn}
      # si el usuario no existe, dummy_checkpw() simula el chequeo de contraseña
      # como lo haria checkpw, esto ayuda para los timings attacks.
      true ->
        dummy_checkpw()
        {:error, :not_found, conn}
    end
  end

  def logout(conn) do
    configure_session(conn, drop: true)
  end

  def authenticate_user(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: Helpers.page_path(conn, :index))
      |> halt()
    end
  end

  defp put_current_user(conn, user) do
    token = Phoenix.Token.sign(conn, "user socket", user.id)

    conn
    |> assign(:current_user, user)
    |> assign(:user_token, token)
  end
end
