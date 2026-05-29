defmodule AcademicPerformance.Repo.Migrations.CreateDisciplinesTable do
  use Ecto.Migration

  def change do
    create table(:disciplines, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :code, :string, null: false
      add :semester, :integer, null: false
      add :credits, :integer
      add :workload, :integer

      timestamps(type: :utc_datetime)
    end

    create unique_index(:disciplines, [:code])
  end
end
