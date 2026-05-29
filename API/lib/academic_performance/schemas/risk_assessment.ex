defmodule AcademicPerformance.Schemas.RiskAssessment do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "risk_assessments" do
    field :risk_level, Ecto.Enum, values: [:low, :medium, :high, :critical]
    field :dropout_probability, :decimal
    field :failure_probability, :decimal
    field :assessment_date, :utc_datetime
    field :notes, :string

    belongs_to :student, AcademicPerformance.Schemas.Student

    timestamps(type: :utc_datetime)
  end

  def changeset(assessment, attrs) do
    assessment
    |> cast(attrs, [:risk_level, :dropout_probability, :failure_probability, :assessment_date, :notes, :student_id])
    |> validate_required([:risk_level, :dropout_probability, :failure_probability, :student_id])
    |> validate_number(:dropout_probability, greater_than_or_equal_to: 0, less_than_or_equal_to: 100)
    |> validate_number(:failure_probability, greater_than_or_equal_to: 0, less_than_or_equal_to: 100)
    |> assoc_constraint(:student)
  end
end
