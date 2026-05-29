defmodule AcademicPerformance.Schemas.Enrollment do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "enrollments" do
    field :enrollment_date, :utc_datetime
    field :status, Ecto.Enum, values: [:active, :completed, :dropped], default: :active

    belongs_to :student, AcademicPerformance.Schemas.Student
    belongs_to :discipline, AcademicPerformance.Schemas.Discipline

    has_many :academic_records, AcademicPerformance.Schemas.AcademicRecord

    timestamps(type: :utc_datetime)
  end

  def changeset(enrollment, attrs) do
    enrollment
    |> cast(attrs, [:enrollment_date, :status, :student_id, :discipline_id])
    |> validate_required([:enrollment_date, :student_id, :discipline_id])
    |> assoc_constraint(:student)
    |> assoc_constraint(:discipline)
    |> unique_constraint([:student_id, :discipline_id])
  end
end
