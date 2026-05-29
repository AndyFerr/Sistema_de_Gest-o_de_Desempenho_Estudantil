defmodule AcademicPerformance.Web.RiskAssessmentController do
  use Phoenix.Controller
  require Logger

  alias AcademicPerformance.Services.RiskEngine
  alias AcademicPerformance.Services.AlertService
  alias AcademicPerformance.Web.FallbackController

  action_fallback FallbackController

  def index(conn, params) do
    assessments = case params do
      %{"student_id" => student_id} ->
        RiskEngine.get_student_risk_assessments(student_id)
      _ ->
        []
    end

    json(conn, %{data: assessments})
  end

  def create(conn, %{"student_id" => student_id, "risk_assessment" => assessment_params}) do
    with {:ok, assessment} <- RiskEngine.create_risk_assessment(student_id, assessment_params) do
      AlertService.generate_alerts_for_assessment(assessment)

      conn
      |> put_status(:created)
      |> json(%{data: assessment})
    end
  end

  def show(conn, %{"id" => id}) do
    assessment = RiskEngine.get_latest_risk_assessment(id)

    case assessment do
      nil -> json(conn, %{data: nil})
      _ -> json(conn, %{data: assessment})
    end
  end
end
