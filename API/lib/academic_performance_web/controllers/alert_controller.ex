defmodule AcademicPerformance.Web.AlertController do
  use Phoenix.Controller
  require Logger

  alias AcademicPerformance.Services.AlertService
  alias AcademicPerformance.Web.FallbackController

  action_fallback FallbackController

  def index(conn, params) do
    alerts = case params do
      %{"risk_assessment_id" => risk_assessment_id} ->
        AlertService.get_risk_alerts(risk_assessment_id)
      _ ->
        []
    end

    json(conn, %{data: alerts})
  end

  def show(conn, %{"id" => id}) do
    alerts = AlertService.get_active_alerts(id)
    json(conn, %{data: alerts})
  end

  def update(conn, %{"id" => alert_id, "alert" => %{"is_read" => true}}) do
    with {:ok, alert} <- AlertService.mark_alert_as_read(alert_id) do
      json(conn, %{data: alert})
    end
  end

  def update(conn, %{"id" => alert_id, "alert" => %{"dismissed" => true}}) do
    with {:ok, alert} <- AlertService.dismiss_alert(alert_id) do
      json(conn, %{data: alert})
    end
  end
end
