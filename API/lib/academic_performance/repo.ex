defmodule AcademicPerformance.Repo do
  use Ecto.Repo,
    otp_app: :academic_performance,
    adapter: Ecto.Adapters.Postgres
end
