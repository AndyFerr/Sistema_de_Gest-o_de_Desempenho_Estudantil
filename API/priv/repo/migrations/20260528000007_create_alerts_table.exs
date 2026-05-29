defmodule AcademicPerformance.Repo.Migrations.CreateAlertsTable do
  use Ecto.Migration

  def change do
    create table(:alerts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :message, :string, null: false
      add :severity, :string, default: "info"
      add :alert_type, :string, null: false
      add :is_read, :boolean, default: false
      add :dismissed_at, :utc_datetime
      add :risk_assessment_id, references(:risk_assessments, type: :binary_id, on_delete: :cascade), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:alerts, [:risk_assessment_id])
    create index(:alerts, [:severity])
  end
end
