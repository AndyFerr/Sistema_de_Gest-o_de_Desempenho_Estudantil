defmodule AcademicPerformance.Repo.Migrations.CreateRiskAssessmentsTable do
  use Ecto.Migration

  def change do
    create table(:risk_assessments, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :risk_level, :string, null: false
      add :dropout_probability, :decimal, precision: 5, scale: 2, null: false
      add :failure_probability, :decimal, precision: 5, scale: 2, null: false
      add :assessment_date, :utc_datetime
      add :notes, :text
      add :student_id, references(:students, type: :binary_id, on_delete: :cascade), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:risk_assessments, [:student_id])
    create index(:risk_assessments, [:assessment_date])
  end
end
