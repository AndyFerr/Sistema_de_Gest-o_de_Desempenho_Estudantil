defmodule AcademicPerformance.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      AcademicPerformance.Repo,
      {Phoenix.PubSub, name: AcademicPerformance.PubSub},
      AcademicPerformance.Web.Endpoint
    ]

    opts = [strategy: :one_for_one, name: AcademicPerformance.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    AcademicPerformance.Web.Endpoint.config_change(changed, removed)
    :ok
  end
end
