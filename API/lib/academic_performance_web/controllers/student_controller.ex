defmodule AcademicPerformance.Web.StudentController do
  use Phoenix.Controller
  require Logger

  alias AcademicPerformance.Context.Students
  alias AcademicPerformance.Services.RiskEngine
  alias AcademicPerformance.Web.FallbackController

  action_fallback FallbackController

  def index(conn, _params) do
    students = Students.list_students()
    json(conn, %{data: students})
  end

  def create(conn, %{"student" => student_params}) do
    with {:ok, student} <- Students.create_student(student_params) do
      conn
      |> put_status(:created)
      |> json(%{data: student})
    end
  end

  def show(conn, %{"id" => id}) do
    student = Students.get_student!(id)
    json(conn, %{data: student})
  end

  def performance(conn, %{"id" => id}) do
    performance = Students.get_student_performance(id)
    json(conn, %{data: performance})
  end

  def risk_profile(conn, %{"id" => id}) do
    risk_data = RiskEngine.assess_student_risk(id)
    assessments = RiskEngine.get_student_risk_assessments(id)

    json(conn, %{
      data: %{
        current_assessment: risk_data,
        historical_assessments: assessments
      }
    })
  end

  def update(conn, %{"id" => id, "student" => student_params}) do
    student = Students.get_student!(id)

    with {:ok, updated_student} <- Students.update_student(student, student_params) do
      json(conn, %{data: updated_student})
    end
  end

  def delete(conn, %{"id" => id}) do
    student = Students.get_student!(id)

    with {:ok, _student} <- Students.delete_student(student) do
      send_resp(conn, :no_content, "")
    end
  end
end
