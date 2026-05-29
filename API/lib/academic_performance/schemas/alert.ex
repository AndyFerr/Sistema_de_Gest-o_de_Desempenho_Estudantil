defmodule AcademicPerformance.Schemas.Alert do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "alerts" do
    field :message, :string
    field :severity, Ecto.Enum, values: [:info, :warning, :critical], default: :info
    field :alert_type, Ecto.Enum, values: [:low_grade, :low_attendance, :dropout_risk, :failure_risk]
    field :is_read, :boolean, default: false
    field :dismissed_at, :utc_datetime

    belongs_to :risk_assessment, AcademicPerformance.Schemas.RiskAssessment

    timestamps(type: :utc_datetime)
  end

  def changeset(alert, attrs) do
    alert
    |> cast(attrs, [:message, :severity, :alert_type, :is_read, :dismissed_at, :risk_assessment_id])
    |> validate_required([:message, :alert_type, :risk_assessment_id])
    |> assoc_constraint(:risk_assessment)
  end
end
