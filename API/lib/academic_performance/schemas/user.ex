defmodule AcademicPerformance.Schemas.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "users" do
    field :email, :string
    field :password_hash, :string
    field :role, Ecto.Enum, values: [:admin, :teacher, :manager]
    field :full_name, :string
    field :active, :boolean, default: true

    has_many :teacher_disciplines, AcademicPerformance.Schemas.TeacherDiscipline
    has_many :reports, AcademicPerformance.Schemas.Report

    timestamps(type: :utc_datetime)
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password_hash, :role, :full_name, :active])
    |> validate_required([:email, :role])
    |> unique_constraint(:email)
  end
end
