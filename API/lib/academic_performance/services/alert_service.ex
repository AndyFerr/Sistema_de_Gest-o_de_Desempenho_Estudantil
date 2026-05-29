defmodule AcademicPerformance.Services.AlertService do
  alias AcademicPerformance.Repo
  alias AcademicPerformance.Schemas.Alert
  import Ecto.Query

  def create_alert(risk_assessment_id, alert_type, message, severity) do
    %Alert{}
    |> Alert.changeset(%{
      risk_assessment_id: risk_assessment_id,
      alert_type: alert_type,
      message: message,
      severity: severity
    })
    |> Repo.insert()
  end

  def get_risk_alerts(risk_assessment_id) do
    from(a in Alert, where: a.risk_assessment_id == ^risk_assessment_id)
    |> Repo.all()
  end

  def get_active_alerts(risk_assessment_id) do
    from(a in Alert,
      where: a.risk_assessment_id == ^risk_assessment_id and is_nil(a.dismissed_at)
    )
    |> Repo.all()
  end

  def mark_alert_as_read(alert_id) do
    alert = Repo.get!(Alert, alert_id)

    alert
    |> Alert.changeset(%{is_read: true})
    |> Repo.update()
  end

  def dismiss_alert(alert_id) do
    alert = Repo.get!(Alert, alert_id)

    alert
    |> Alert.changeset(%{dismissed_at: DateTime.utc_now()})
    |> Repo.update()
  end

  def generate_alerts_for_assessment(risk_assessment) do
    alerts = []

    alerts = add_grade_alert(alerts, risk_assessment)
    alerts = add_attendance_alert(alerts, risk_assessment)
    alerts = add_dropout_risk_alert(alerts, risk_assessment)
    alerts = add_failure_risk_alert(alerts, risk_assessment)

    Enum.each(alerts, fn alert_data ->
      create_alert(
        risk_assessment.id,
        alert_data.type,
        alert_data.message,
        alert_data.severity
      )
    end)
  end

  defp add_grade_alert(alerts, risk_assessment) do
    if risk_assessment.failure_probability > 60 do
      [%{
        type: :low_grade,
        message: "Student has high failure probability (#{risk_assessment.failure_probability}%)",
        severity: :critical
      } | alerts]
    else
      alerts
    end
  end

  defp add_attendance_alert(alerts, _risk_assessment) do
    alerts
  end

  defp add_dropout_risk_alert(alerts, risk_assessment) do
    if risk_assessment.dropout_probability > 50 do
      [%{
        type: :dropout_risk,
        message: "Student shows risk of dropout (#{risk_assessment.dropout_probability}%)",
        severity: :critical
      } | alerts]
    else
      alerts
    end
  end

  defp add_failure_risk_alert(alerts, risk_assessment) do
    if risk_assessment.failure_probability > 50 do
      [%{
        type: :failure_risk,
        message: "Student may fail the course",
        severity: :warning
      } | alerts]
    else
      alerts
    end
  end
end
