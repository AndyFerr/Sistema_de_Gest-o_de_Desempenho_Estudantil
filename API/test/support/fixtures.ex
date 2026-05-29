defmodule AcademicPerformance.Fixtures do
  alias AcademicPerformance.Repo
  alias AcademicPerformance.Schemas.{
    User, Student, Discipline, Enrollment, AcademicRecord
  }

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: "user#{System.unique_integer()}@example.com",
        role: :teacher,
        full_name: "Test User",
        active: true
      })
      |> then(&User.changeset(%User{}, &1))
      |> Repo.insert()

    user
  end

  def student_fixture(attrs \\ %{}) do
    {:ok, student} =
      attrs
      |> Enum.into(%{
        registration_number: "REG#{System.unique_integer()}",
        full_name: "Test Student",
        email: "student#{System.unique_integer()}@example.com",
        status: :registered
      })
      |> then(&Student.changeset(%Student{}, &1))
      |> Repo.insert()

    student
  end

  def discipline_fixture(attrs \\ %{}) do
    {:ok, discipline} =
      attrs
      |> Enum.into(%{
        name: "Test Discipline",
        code: "TEST#{System.unique_integer()}",
        semester: 1,
        credits: 4,
        workload: 60
      })
      |> then(&Discipline.changeset(%Discipline{}, &1))
      |> Repo.insert()

    discipline
  end

  def enrollment_fixture(attrs \\ %{}) do
    student = Map.get_lazy(attrs, :student, &student_fixture/0)
    discipline = Map.get_lazy(attrs, :discipline, &discipline_fixture/0)

    {:ok, enrollment} =
      %{
        enrollment_date: DateTime.utc_now(),
        student_id: student.id,
        discipline_id: discipline.id,
        status: :active
      }
      |> Enum.into(attrs)
      |> then(&Enrollment.changeset(%Enrollment{}, &1))
      |> Repo.insert()

    enrollment
  end

  def academic_record_fixture(attrs \\ %{}) do
    student = Map.get_lazy(attrs, :student, &student_fixture/0)
    discipline = Map.get_lazy(attrs, :discipline, &discipline_fixture/0)

    {:ok, record} =
      %{
        grade: Decimal.new("8.5"),
        attendance_percentage: Decimal.new("90"),
        recorded_date: DateTime.utc_now(),
        student_id: student.id,
        discipline_id: discipline.id
      }
      |> Enum.into(attrs)
      |> then(&AcademicRecord.changeset(%AcademicRecord{}, &1))
      |> Repo.insert()

    record
  end
end
