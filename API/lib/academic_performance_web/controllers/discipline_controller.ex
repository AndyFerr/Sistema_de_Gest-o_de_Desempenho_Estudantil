defmodule AcademicPerformance.Web.DisciplineController do
  use Phoenix.Controller
  require Logger

  alias AcademicPerformance.Context.Disciplines
  alias AcademicPerformance.Web.FallbackController

  action_fallback FallbackController

  def index(conn, params) do
    disciplines = case params do
      %{"semester" => semester} ->
        {sem, _} = Integer.parse(semester)
        Disciplines.list_disciplines_by_semester(sem)
      _ ->
        Disciplines.list_disciplines()
    end

    json(conn, %{data: disciplines})
  end

  def create(conn, %{"discipline" => discipline_params}) do
    with {:ok, discipline} <- Disciplines.create_discipline(discipline_params) do
      conn
      |> put_status(:created)
      |> json(%{data: discipline})
    end
  end

  def show(conn, %{"id" => id}) do
    discipline = Disciplines.get_discipline!(id)
    json(conn, %{data: discipline})
  end

  def stats(conn, %{"id" => id}) do
    stats = Disciplines.get_discipline_stats(id)
    json(conn, %{data: stats})
  end

  def update(conn, %{"id" => id, "discipline" => discipline_params}) do
    discipline = Disciplines.get_discipline!(id)

    with {:ok, updated_discipline} <- Disciplines.update_discipline(discipline, discipline_params) do
      json(conn, %{data: updated_discipline})
    end
  end

  def delete(conn, %{"id" => id}) do
    discipline = Disciplines.get_discipline!(id)

    with {:ok, _discipline} <- Disciplines.delete_discipline(discipline) do
      send_resp(conn, :no_content, "")
    end
  end
end
