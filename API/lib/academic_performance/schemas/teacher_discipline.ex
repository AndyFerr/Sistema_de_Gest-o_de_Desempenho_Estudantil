defmodule AcademicPerformance.Schemas.TeacherDiscipline do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "teacher_disciplines" do
    field :assignment_date, :utc_datetime

    belongs_to :user, AcademicPerformance.Schemas.User
    belongs_to :discipline, AcademicPerformance.Schemas.Discipline

    timestamps(type: :utc_datetime)
  end

  def changeset(assignment, attrs) do
    assignment
    |> cast(attrs, [:assignment_date, :user_id, :discipline_id])
    |> validate_required([:user_id, :discipline_id])
    |> assoc_constraint(:user)
    |> assoc_constraint(:discipline)
    |> unique_constraint([:user_id, :discipline_id])
  end
end
