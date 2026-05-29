defmodule AcademicPerformance.Schemas.Discipline do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "disciplines" do
    field :name, :string
    field :code, :string
    field :semester, :integer
    field :credits, :integer
    field :workload, :integer

    has_many :enrollments, AcademicPerformance.Schemas.Enrollment
    has_many :teacher_disciplines, AcademicPerformance.Schemas.TeacherDiscipline
    has_many :academic_records, AcademicPerformance.Schemas.AcademicRecord

    timestamps(type: :utc_datetime)
  end

  def changeset(discipline, attrs) do
    discipline
    |> cast(attrs, [:name, :code, :semester, :credits, :workload])
    |> validate_required([:name, :code, :semester])
    |> unique_constraint(:code)
  end
end
