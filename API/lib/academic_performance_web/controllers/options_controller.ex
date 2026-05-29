defmodule AcademicPerformance.Web.OptionsController do
  use Phoenix.Controller

  def handle_options(conn, _opts) do
    conn
    |> put_resp_header("access-control-allow-methods", "GET, POST, PUT, DELETE, OPTIONS")
    |> put_resp_header("access-control-allow-headers", "Content-Type, Authorization")
    |> send_resp(:no_content, "")
  end
end
