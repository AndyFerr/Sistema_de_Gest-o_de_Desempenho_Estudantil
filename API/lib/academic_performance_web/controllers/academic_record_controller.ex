defmodule AcademicPerformance.Web.AcademicRecordController do
  use Phoenix.Controller
  require Logger

  alias AcademicPerformance.Context.AcademicRecords
  alias AcademicPerformance.Web.FallbackController

  action_fallback FallbackController

  def index(conn, params) do
    records = case params do
      %{"student_id" => student_id} ->
        AcademicRecords.list_student_records(student_id)
      %{"discipline_id" => discipline_id} ->
        AcademicRecords.list_discipline_records(discipline_id)
      _ ->
        []
    end

    json(conn, %{data: records})
  end

  def create(conn, %{"academic_record" => record_params}) do
    with {:ok, record} <- AcademicRecords.create_record(record_params) do
      conn
      |> put_status(:created)
      |> json(%{data: record})
    end
  end

  def show(conn, %{"id" => id}) do
    record = AcademicRecords.get_record!(id)
    json(conn, %{data: record})
  end

  def update(conn, %{"id" => id, "academic_record" => record_params}) do
    record = AcademicRecords.get_record!(id)

    with {:ok, updated_record} <- AcademicRecords.update_record(record, record_params) do
      json(conn, %{data: updated_record})
    end
  end

  def delete(conn, %{"id" => id}) do
    record = AcademicRecords.get_record!(id)

    with {:ok, _record} <- AcademicRecords.delete_record(record) do
      send_resp(conn, :no_content, "")
    end
  end
end
