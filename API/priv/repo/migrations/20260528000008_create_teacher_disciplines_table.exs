defmodule AcademicPerformance.Repo.Migrations.CreateTeacherDisciplinesTable do
  use Ecto.Migration

  def change do
    create table(:teacher_disciplines, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :assignment_date, :utc_datetime
      add :user_id, references(:users, type: :binary_id, on_delete: :cascade), null: false
      add :discipline_id, references(:disciplines, type: :binary_id, on_delete: :cascade), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:teacher_disciplines, [:user_id])
    create index(:teacher_disciplines, [:discipline_id])
    create unique_index(:teacher_disciplines, [:user_id, :discipline_id])
  end
end
