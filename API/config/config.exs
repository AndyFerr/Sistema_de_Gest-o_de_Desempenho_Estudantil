import Config

config :academic_performance, ecto_repos: [AcademicPerformance.Repo]

config :academic_performance, AcademicPerformance.Repo,
  migration_primary_key: [type: :binary_id],
  migration_foreign_key: [type: :binary_id]

config :academic_performance, AcademicPerformance.Web.Endpoint,
  adapter: Plug.Cowboy,
  http: [port: 4000],
  url: [host: "localhost"],
  render_errors: [
    formats: [json: AcademicPerformance.Web.ErrorJSON],
    layout: false
  ],
  pubsub_server: AcademicPerformance.PubSub,
  live_view: [signing_salt: "academic_perf_salt"]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{config_env()}.exs"
