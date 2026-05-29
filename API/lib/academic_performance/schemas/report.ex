defmodule AcademicPerformance.Schemas.Report do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "reports" do
    field :title, :string
    field :report_type, Ecto.Enum, values: [:cohort, :discipline, :individual, :risk_analysis]
    field :period_start, :utc_datetime
    field :period_end, :utc_datetime
    field :data, :map
    field :generated_at, :utc_datetime

    belongs_to :user, AcademicPerformance.Schemas.User

    timestamps(type: :utc_datetime)
  end

  def changeset(report, attrs) do
    report
    |> cast(attrs, [:title, :report_type, :period_start, :period_end, :data, :generated_at, :user_id])
    |> validate_required([:title, :report_type, :user_id])
    |> assoc_constraint(:user)
  end
end
