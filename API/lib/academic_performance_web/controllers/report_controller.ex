defmodule AcademicPerformance.Web.ReportController do
  use Phoenix.Controller
  require Logger

  alias AcademicPerformance.Services.ReportService
  alias AcademicPerformance.Web.FallbackController

  action_fallback FallbackController

  def index(conn, %{"user_id" => user_id}) do
    reports = ReportService.list_user_reports(user_id)
    json(conn, %{data: reports})
  end

  def show(conn, %{"id" => id}) do
    report = ReportService.get_report!(id)
    json(conn, %{data: report})
  end

  def cohort(conn, %{"user_id" => user_id, "period_start" => period_start, "period_end" => period_end}) do
    {:ok, start_date, _} = DateTime.from_iso8601(period_start)
    {:ok, end_date, _} = DateTime.from_iso8601(period_end)

    with {:ok, report} <- ReportService.create_cohort_report(user_id, start_date, end_date) do
      conn
      |> put_status(:created)
      |> json(%{data: report})
    end
  end

  def discipline(conn, %{
    "user_id" => user_id,
    "discipline_id" => discipline_id,
    "period_start" => period_start,
    "period_end" => period_end
  }) do
    {:ok, start_date, _} = DateTime.from_iso8601(period_start)
    {:ok, end_date, _} = DateTime.from_iso8601(period_end)

    with {:ok, report} <- ReportService.create_discipline_report(user_id, discipline_id, start_date, end_date) do
      conn
      |> put_status(:created)
      |> json(%{data: report})
    end
  end

  def individual(conn, %{
    "user_id" => user_id,
    "student_id" => student_id,
    "period_start" => period_start,
    "period_end" => period_end
  }) do
    {:ok, start_date, _} = DateTime.from_iso8601(period_start)
    {:ok, end_date, _} = DateTime.from_iso8601(period_end)

    with {:ok, report} <- ReportService.create_individual_report(user_id, student_id, start_date, end_date) do
      conn
      |> put_status(:created)
      |> json(%{data: report})
    end
  end

  def risk_analysis(conn, %{
    "user_id" => user_id,
    "period_start" => period_start,
    "period_end" => period_end
  }) do
    {:ok, start_date, _} = DateTime.from_iso8601(period_start)
    {:ok, end_date, _} = DateTime.from_iso8601(period_end)

    with {:ok, report} <- ReportService.create_risk_analysis_report(user_id, start_date, end_date) do
      conn
      |> put_status(:created)
      |> json(%{data: report})
    end
  end
end
