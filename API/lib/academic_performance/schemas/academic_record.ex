defmodule AcademicPerformance.Schemas.AcademicRecord do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "academic_records" do
    field :grade, :decimal
    field :attendance_percentage, :decimal
    field :recorded_date, :utc_datetime

    belongs_to :student, AcademicPerformance.Schemas.Student
    belongs_to :discipline, AcademicPerformance.Schemas.Discipline
    belongs_to :enrollment, AcademicPerformance.Schemas.Enrollment

    timestamps(type: :utc_datetime)
  end

  def changeset(record, attrs) do
    record
    |> cast(attrs, [:grade, :attendance_percentage, :recorded_date, :student_id, :discipline_id, :enrollment_id])
    |> validate_required([:grade, :attendance_percentage, :student_id, :discipline_id])
    |> validate_number(:grade, greater_than_or_equal_to: 0, less_than_or_equal_to: 10)
    |> validate_number(:attendance_percentage, greater_than_or_equal_to: 0, less_than_or_equal_to: 100)
    |> assoc_constraint(:student)
    |> assoc_constraint(:discipline)
  end
end
