defmodule AcademicPerformance.Repo.Migrations.CreateEnrollmentsTable do
  use Ecto.Migration

  def change do
    create table(:enrollments, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :enrollment_date, :utc_datetime, null: false
      add :status, :string, default: "active"
      add :student_id, references(:students, type: :binary_id, on_delete: :cascade), null: false
      add :discipline_id, references(:disciplines, type: :binary_id, on_delete: :cascade), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:enrollments, [:student_id])
    create index(:enrollments, [:discipline_id])
    create unique_index(:enrollments, [:student_id, :discipline_id])
  end
end
