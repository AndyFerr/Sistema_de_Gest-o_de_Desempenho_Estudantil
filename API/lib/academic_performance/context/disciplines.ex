defmodule AcademicPerformance.Context.Disciplines do
  import Ecto.Query
  alias AcademicPerformance.Repo
  alias AcademicPerformance.Schemas.Discipline

  def list_disciplines do
    Repo.all(Discipline)
  end

  def list_disciplines_by_semester(semester) do
    from(d in Discipline, where: d.semester == ^semester)
    |> Repo.all()
  end

  def get_discipline!(id) do
    Discipline
    |> Repo.get!(id)
    |> Repo.preload([:enrollments, :teacher_disciplines, :academic_records])
  end

  def get_discipline_by_code(code) do
    Repo.get_by(Discipline, code: code)
  end

  def create_discipline(attrs \\ %{}) do
    %Discipline{}
    |> Discipline.changeset(attrs)
    |> Repo.insert()
  end

  def update_discipline(%Discipline{} = discipline, attrs) do
    discipline
    |> Discipline.changeset(attrs)
    |> Repo.update()
  end

  def delete_discipline(%Discipline{} = discipline) do
    Repo.delete(discipline)
  end

  def get_discipline_stats(discipline_id) do
    discipline = get_discipline!(discipline_id)
    records = Repo.preload(discipline.academic_records, :student)

    %{
      discipline: discipline,
      total_students: length(discipline.enrollments),
      avg_grade: calculate_avg_grade(records),
      avg_attendance: calculate_avg_attendance(records),
      at_risk_count: count_at_risk(records)
    }
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

  defp count_at_risk(records) do
    records
    |> Enum.count(&low_performance?/1)
  end

  defp low_performance?(record) do
    grade = Decimal.to_float(record.grade)
    attendance = Decimal.to_float(record.attendance_percentage)
    grade < 6.0 or attendance < 75
  end
end
