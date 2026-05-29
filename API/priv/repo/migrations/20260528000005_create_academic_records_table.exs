defmodule AcademicPerformance.Repo.Migrations.CreateAcademicRecordsTable do
  use Ecto.Migration

  def change do
    create table(:academic_records, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :grade, :decimal, precision: 5, scale: 2, null: false
      add :attendance_percentage, :decimal, precision: 5, scale: 2, null: false
      add :recorded_date, :utc_datetime
      add :student_id, references(:students, type: :binary_id, on_delete: :cascade), null: false
      add :discipline_id, references(:disciplines, type: :binary_id, on_delete: :cascade), null: false
      add :enrollment_id, references(:enrollments, type: :binary_id, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:academic_records, [:student_id])
    create index(:academic_records, [:discipline_id])
    create index(:academic_records, [:enrollment_id])
  end
end
