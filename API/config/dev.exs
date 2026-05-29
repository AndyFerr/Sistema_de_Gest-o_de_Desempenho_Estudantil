import Config

config :academic_performance, AcademicPerformance.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "academic_performance_dev",
  stacktrace: true,
  show_sensitive_data_on_error: true,
  pool_size: 10

config :academic_performance, AcademicPerformance.Web.Endpoint,
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: []
