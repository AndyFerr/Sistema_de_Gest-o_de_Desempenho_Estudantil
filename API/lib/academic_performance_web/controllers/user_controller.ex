defmodule AcademicPerformance.Web.UserController do
  use Phoenix.Controller
  require Logger

  alias AcademicPerformance.Context.Users
  alias AcademicPerformance.Web.FallbackController

  action_fallback FallbackController

  def index(conn, _params) do
    users = Users.list_users()
    json(conn, %{data: users})
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, user} <- Users.create_user(user_params) do
      conn
      |> put_status(:created)
      |> json(%{data: user})
    end
  end

  def show(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    json(conn, %{data: user})
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Users.get_user!(id)

    with {:ok, updated_user} <- Users.update_user(user, user_params) do
      json(conn, %{data: updated_user})
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Users.get_user!(id)

    with {:ok, _user} <- Users.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end
