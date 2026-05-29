defmodule AcademicPerformance.Repo.Migrations.CreateStudentsTable do
  use Ecto.Migration

  def change do
    create table(:students, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :registration_number, :string, null: false
      add :full_name, :string, null: false
      add :email, :string, null: false
      add :status, :string, default: "registered"

      timestamps(type: :utc_datetime)
    end

    create unique_index(:students, [:registration_number])
    create unique_index(:students, [:email])
  end
end
