defmodule AcademicPerformance.Services.ReportService do
  alias AcademicPerformance.Repo
  alias AcademicPerformance.Schemas.Report
  alias AcademicPerformance.Context.{Students, Disciplines, AcademicRecords}
  import Ecto.Query

  def create_cohort_report(user_id, period_start, period_end) do
    students = Students.list_active_students()
    records = list_records_in_period(period_start, period_end)

    data = %{
      total_students: length(students),
      average_grade: calculate_avg_grade(records),
      average_attendance: calculate_avg_attendance(records),
      at_risk_count: count_at_risk_students(records),
      critical_risk_count: count_critical_risk(records)
    }

    %Report{}
    |> Report.changeset(%{
      title: "Cohort Performance Report",
      report_type: :cohort,
      period_start: period_start,
      period_end: period_end,
      data: data,
      user_id: user_id,
      generated_at: DateTime.utc_now()
    })
    |> Repo.insert()
  end

  def create_discipline_report(user_id, discipline_id, period_start, period_end) do
    discipline = Disciplines.get_discipline!(discipline_id)
    records = AcademicRecords.list_discipline_records(discipline_id)

    filtered_records = Enum.filter(records, fn r ->
      DateTime.compare(r.recorded_date, period_start) in [:gt, :eq] and
      DateTime.compare(r.recorded_date, period_end) in [:lt, :eq]
    end)

    data = %{
      discipline_name: discipline.name,
      discipline_code: discipline.code,
      total_students: length(filtered_records),
      average_grade: calculate_avg_grade(filtered_records),
      average_attendance: calculate_avg_attendance(filtered_records),
      at_risk_count: count_at_risk_students(filtered_records)
    }

    %Report{}
    |> Report.changeset(%{
      title: "Discipline Report: #{discipline.name}",
      report_type: :discipline,
      period_start: period_start,
      period_end: period_end,
      data: data,
      user_id: user_id,
      generated_at: DateTime.utc_now()
    })
    |> Repo.insert()
  end

  def create_individual_report(user_id, student_id, period_start, period_end) do
    student = Students.get_student!(student_id)
    records = AcademicRecords.list_student_records(student_id)

    filtered_records = Enum.filter(records, fn r ->
      DateTime.compare(r.recorded_date, period_start) in [:gt, :eq] and
      DateTime.compare(r.recorded_date, period_end) in [:lt, :eq]
    end)

    data = %{
      student_name: student.full_name,
      student_registration: student.registration_number,
      average_grade: calculate_avg_grade(filtered_records),
      average_attendance: calculate_avg_attendance(filtered_records),
      disciplines_count: length(filtered_records),
      status: Atom.to_string(student.status)
    }

    %Report{}
    |> Report.changeset(%{
      title: "Individual Report: #{student.full_name}",
      report_type: :individual,
      period_start: period_start,
      period_end: period_end,
      data: data,
      user_id: user_id,
      generated_at: DateTime.utc_now()
    })
    |> Repo.insert()
  end

  def create_risk_analysis_report(user_id, period_start, period_end) do
    risk_assessments = list_risk_assessments_in_period(period_start, period_end)

    data = %{
      total_assessed: length(risk_assessments),
      high_risk_count: count_by_level(risk_assessments, :high),
      critical_risk_count: count_by_level(risk_assessments, :critical),
      medium_risk_count: count_by_level(risk_assessments, :medium),
      low_risk_count: count_by_level(risk_assessments, :low),
      average_dropout_probability: calculate_avg_dropout(risk_assessments),
      average_failure_probability: calculate_avg_failure(risk_assessments)
    }

    %Report{}
    |> Report.changeset(%{
      title: "Risk Analysis Report",
      report_type: :risk_analysis,
      period_start: period_start,
      period_end: period_end,
      data: data,
      user_id: user_id,
      generated_at: DateTime.utc_now()
    })
    |> Repo.insert()
  end

  def list_user_reports(user_id) do
    from(r in Report, where: r.user_id == ^user_id)
    |> Repo.all()
  end

  def get_report!(id), do: Repo.get!(Report, id)

  defp list_records_in_period(period_start, period_end) do
    from(r in AcademicRecords,
      where: r.recorded_date >= ^period_start and r.recorded_date <= ^period_end
    )
    |> Repo.all()
  end

  defp list_risk_assessments_in_period(period_start, period_end) do
    from(a in AcademicPerformance.Schemas.RiskAssessment,
      where: a.assessment_date >= ^period_start and a.assessment_date <= ^period_end
    )
    |> Repo.all()
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

  defp count_at_risk_students(records) do
    records
    |> Enum.count(&low_performance?/1)
  end

  defp count_critical_risk(records) do
    records
    |> Enum.count(&critical_performance?/1)
  end

  defp low_performance?(record) do
    grade = Decimal.to_float(record.grade)
    attendance = Decimal.to_float(record.attendance_percentage)
    grade < 6.0 or attendance < 75
  end

  defp critical_performance?(record) do
    grade = Decimal.to_float(record.grade)
    attendance = Decimal.to_float(record.attendance_percentage)
    grade < 4.0 or attendance < 50
  end

  defp count_by_level(assessments, level) do
    Enum.count(assessments, &(&1.risk_level == level))
  end

  defp calculate_avg_dropout(assessments) do
    case assessments do
      [] -> 0
      _ ->
        assessments
        |> Enum.map(&Decimal.to_float/1)
        |> Enum.sum()
        |> (&(&1 / length(assessments))).()
        |> Float.round(2)
    end
  end

  defp calculate_avg_failure(assessments) do
    case assessments do
      [] -> 0
      _ ->
        assessments
        |> Enum.map(&Decimal.to_float/1)
        |> Enum.sum()
        |> (&(&1 / length(assessments))).()
        |> Float.round(2)
    end
  end
end
