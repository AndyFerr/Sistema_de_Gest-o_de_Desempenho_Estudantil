defmodule AcademicPerformance.Repo.Migrations.CreateReportsTable do
  use Ecto.Migration

  def change do
    create table(:reports, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string, null: false
      add :report_type, :string, null: false
      add :period_start, :utc_datetime
      add :period_end, :utc_datetime
      add :data, :map
      add :generated_at, :utc_datetime
      add :user_id, references(:users, type: :binary_id, on_delete: :cascade), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:reports, [:user_id])
    create index(:reports, [:report_type])
    create index(:reports, [:generated_at])
  end
end
