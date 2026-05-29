defmodule AcademicPerformance.Services.RiskEngine do
  alias AcademicPerformance.Repo
  alias AcademicPerformance.Schemas.RiskAssessment
  alias AcademicPerformance.Context.AcademicRecords

  @low_grade_threshold 6.0
  @critical_grade_threshold 4.0
  @low_attendance_threshold 75
  @critical_attendance_threshold 50

  def assess_student_risk(student_id) do
    records = AcademicRecords.list_student_records(student_id)

    case records do
      [] -> nil
      _ ->
        avg_grade = calculate_avg_grade(records)
        avg_attendance = calculate_avg_attendance(records)

        %{
          risk_level: calculate_risk_level(avg_grade, avg_attendance),
          dropout_probability: calculate_dropout_probability(avg_grade, avg_attendance),
          failure_probability: calculate_failure_probability(avg_grade),
          average_grade: avg_grade,
          average_attendance: avg_attendance
        }
    end
  end

  def create_risk_assessment(student_id, assessment_data) do
    %RiskAssessment{}
    |> RiskAssessment.changeset(
      Map.merge(assessment_data, %{
        "student_id" => student_id,
        "assessment_date" => DateTime.utc_now()
      })
    )
    |> Repo.insert()
  end

  def get_student_risk_assessments(student_id) do
    from(r in RiskAssessment, where: r.student_id == ^student_id)
    |> Repo.all()
  end

  def get_latest_risk_assessment(student_id) do
    from(r in RiskAssessment,
      where: r.student_id == ^student_id,
      order_by: [desc: r.assessment_date],
      limit: 1
    )
    |> Repo.one()
  end

  defp calculate_risk_level(avg_grade, avg_attendance) do
    cond do
      avg_grade < @critical_grade_threshold or avg_attendance < @critical_attendance_threshold -> :critical
      avg_grade < @low_grade_threshold or avg_attendance < @low_attendance_threshold -> :high
      avg_grade < 7.0 or avg_attendance < 85 -> :medium
      true -> :low
    end
  end

  defp calculate_dropout_probability(avg_grade, avg_attendance) do
    grade_factor = max(0, (@low_grade_threshold - avg_grade) * 5)
    attendance_factor = max(0, (@low_attendance_threshold - avg_attendance) * 0.5)

    probability = min(100, grade_factor + attendance_factor)
    Float.round(probability, 2)
  end

  defp calculate_failure_probability(avg_grade) do
    case avg_grade do
      grade when grade < @critical_grade_threshold -> 85.0
      grade when grade < @low_grade_threshold -> 60.0
      grade when grade < 7.0 -> 30.0
      _ -> 5.0
    end
  end

  defp calculate_avg_grade(records) do
    case records do
      [] -> 0
      _ ->
        records
        |> Enum.map(&Decimal.to_float/1)
        |> Enum.sum()
        |> (&(&1 / length(records))).()
        |> Float.round(2)
    end
  end

  defp calculate_avg_attendance(records) do
    case records do
      [] -> 0
      _ ->
        records
        |> Enum.map(&(&1.attendance_percentage |> Decimal.to_float()))
        |> Enum.sum()
        |> (&(&1 / length(records))).()
        |> Float.round(2)
    end
  end
end
