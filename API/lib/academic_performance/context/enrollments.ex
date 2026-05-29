defmodule AcademicPerformance.Context.Enrollments do
  import Ecto.Query
  alias AcademicPerformance.Repo
  alias AcademicPerformance.Schemas.Enrollment

  def list_enrollments do
    Repo.all(Enrollment)
  end

  def list_active_enrollments do
    from(e in Enrollment, where: e.status == :active)
    |> Repo.all()
  end

  def list_student_enrollments(student_id) do
    from(e in Enrollment, where: e.student_id == ^student_id)
    |> Repo.all()
    |> Repo.preload(:discipline)
  end

  def list_discipline_enrollments(discipline_id) do
    from(e in Enrollment, where: e.discipline_id == ^discipline_id)
    |> Repo.all()
    |> Repo.preload(:student)
  end

  def get_enrollment!(id) do
    Enrollment
    |> Repo.get!(id)
    |> Repo.preload([:student, :discipline, :academic_records])
  end

  def create_enrollment(attrs \\ %{}) do
    %Enrollment{}
    |> Enrollment.changeset(Map.merge(attrs, %{"enrollment_date" => DateTime.utc_now()}))
    |> Repo.insert()
  end

  def update_enrollment(%Enrollment{} = enrollment, attrs) do
    enrollment
    |> Enrollment.changeset(attrs)
    |> Repo.update()
  end

  def delete_enrollment(%Enrollment{} = enrollment) do
    Repo.delete(enrollment)
  end

  def get_enrollment_with_records(enrollment_id) do
    Enrollment
    |> Repo.get!(enrollment_id)
    |> Repo.preload([academic_records: :discipline, student: :risk_assessments])
  end
end
