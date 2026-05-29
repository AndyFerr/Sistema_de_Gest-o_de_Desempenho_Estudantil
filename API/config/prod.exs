import Config

config :academic_performance, AcademicPerformance.Repo,
  url: System.get_env("DATABASE_URL"),
  pool_size: 20,
  ssl: true

config :academic_performance, AcademicPerformance.Web.Endpoint,
  url: [host: System.get_env("APP_HOST"), port: 80],
  cache_static_manifest: "priv/static/cache_manifest.json"

config :logger, level: :info
