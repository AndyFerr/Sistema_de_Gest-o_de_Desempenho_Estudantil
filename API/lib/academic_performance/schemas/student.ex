defmodule AcademicPerformance.Schemas.Student do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "students" do
    field :registration_number, :string
    field :full_name, :string
    field :email, :string
    field :status, Ecto.Enum, values: [:registered, :enrolled, :approved, :failed, :dropped_out],
      default: :registered

    has_many :enrollments, AcademicPerformance.Schemas.Enrollment
    has_many :academic_records, AcademicPerformance.Schemas.AcademicRecord
    has_many :risk_assessments, AcademicPerformance.Schemas.RiskAssessment

    timestamps(type: :utc_datetime)
  end

  def changeset(student, attrs) do
    student
    |> cast(attrs, [:registration_number, :full_name, :email, :status])
    |> validate_required([:registration_number, :full_name, :email])
    |> unique_constraint(:registration_number)
    |> unique_constraint(:email)
  end
end
