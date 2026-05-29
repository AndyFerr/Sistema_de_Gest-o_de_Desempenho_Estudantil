defmodule AcademicPerformance.Web.Router do
  use Phoenix.Router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", AcademicPerformance.Web do
    pipe_through :api

    resources "/users", UserController, except: [:new, :edit]
    resources "/students", StudentController, except: [:new, :edit]
    resources "/disciplines", DisciplineController, except: [:new, :edit]
    resources "/enrollments", EnrollmentController, except: [:new, :edit]
    resources "/academic-records", AcademicRecordController, except: [:new, :edit]
    resources "/risk-assessments", RiskAssessmentController, except: [:new, :edit]
    resources "/alerts", AlertController, except: [:new, :edit, :create, :update, :delete]
    resources "/reports", ReportController, except: [:new, :edit, :delete]

    get "/students/:id/performance", StudentController, :performance
    get "/students/:id/risk", StudentController, :risk_profile
    get "/disciplines/:id/stats", DisciplineController, :stats
    post "/reports/cohort", ReportController, :cohort
    post "/reports/discipline", ReportController, :discipline
    post "/reports/individual", ReportController, :individual
    post "/reports/risk-analysis", ReportController, :risk_analysis
  end

  match :options, "/*_path", AcademicPerformance.Web.OptionsController, :handle_options
end
