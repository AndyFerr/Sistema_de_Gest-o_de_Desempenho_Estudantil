defmodule AcademicPerformance.Web.EnrollmentController do
  use Phoenix.Controller
  require Logger

  alias AcademicPerformance.Context.Enrollments
  alias AcademicPerformance.Web.FallbackController

  action_fallback FallbackController

  def index(conn, params) do
    enrollments = case params do
      %{"student_id" => student_id} ->
        Enrollments.list_student_enrollments(student_id)
      %{"discipline_id" => discipline_id} ->
        Enrollments.list_discipline_enrollments(discipline_id)
      _ ->
        Enrollments.list_enrollments()
    end

    json(conn, %{data: enrollments})
  end

  def create(conn, %{"enrollment" => enrollment_params}) do
    with {:ok, enrollment} <- Enrollments.create_enrollment(enrollment_params) do
      conn
      |> put_status(:created)
      |> json(%{data: enrollment})
    end
  end

  def show(conn, %{"id" => id}) do
    enrollment = Enrollments.get_enrollment!(id)
    json(conn, %{data: enrollment})
  end

  def update(conn, %{"id" => id, "enrollment" => enrollment_params}) do
    enrollment = Enrollments.get_enrollment!(id)

    with {:ok, updated_enrollment} <- Enrollments.update_enrollment(enrollment, enrollment_params) do
      json(conn, %{data: updated_enrollment})
    end
  end

  def delete(conn, %{"id" => id}) do
    enrollment = Enrollments.get_enrollment!(id)

    with {:ok, _enrollment} <- Enrollments.delete_enrollment(enrollment) do
      send_resp(conn, :no_content, "")
    end
  end
end
