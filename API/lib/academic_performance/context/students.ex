defmodule AcademicPerformance.Context.Students do
  import Ecto.Query
  alias AcademicPerformance.Repo
  alias AcademicPerformance.Schemas.Student

  def list_students do
    Repo.all(Student)
  end

  def list_active_students do
    from(s in Student, where: s.status == :enrolled)
    |> Repo.all()
  end

  def get_student!(id) do
    Student
    |> Repo.get!(id)
    |> Repo.preload([:enrollments, :academic_records, :risk_assessments])
  end

  def get_student_by_registration(registration_number) do
    Repo.get_by(Student, registration_number: registration_number)
  end

  def create_student(attrs \\ %{}) do
    %Student{}
    |> Student.changeset(attrs)
    |> Repo.insert()
  end

  def update_student(%Student{} = student, attrs) do
    student
    |> Student.changeset(attrs)
    |> Repo.update()
  end

  def delete_student(%Student{} = student) do
    Repo.delete(student)
  end

  def get_student_performance(student_id) do
    student = get_student!(student_id)
    records = Repo.preload(student.academic_records, :discipline)

    %{
      student: student,
      records: records,
      avg_grade: calculate_avg_grade(records),
      avg_attendance: calculate_avg_attendance(records)
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
end
