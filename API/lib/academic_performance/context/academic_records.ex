defmodule AcademicPerformance.Context.AcademicRecords do
  import Ecto.Query
  alias AcademicPerformance.Repo
  alias AcademicPerformance.Schemas.AcademicRecord

  def list_student_records(student_id) do
    from(r in AcademicRecord, where: r.student_id == ^student_id)
    |> Repo.all()
    |> Repo.preload(:discipline)
  end

  def list_discipline_records(discipline_id) do
    from(r in AcademicRecord, where: r.discipline_id == ^discipline_id)
    |> Repo.all()
    |> Repo.preload(:student)
  end

  def list_enrollment_records(enrollment_id) do
    from(r in AcademicRecord, where: r.enrollment_id == ^enrollment_id)
    |> Repo.all()
  end

  def get_record!(id) do
    Repo.get!(AcademicRecord, id)
  end

  def create_record(attrs \\ %{}) do
    %AcademicRecord{}
    |> AcademicRecord.changeset(Map.merge(attrs, %{"recorded_date" => DateTime.utc_now()}))
    |> Repo.insert()
  end

  def update_record(%AcademicRecord{} = record, attrs) do
    record
    |> AcademicRecord.changeset(attrs)
    |> Repo.update()
  end

  def delete_record(%AcademicRecord{} = record) do
    Repo.delete(record)
  end

  def bulk_create_records(records_data) do
    Repo.insert_all(AcademicRecord, records_data)
  end

  def get_student_latest_records(student_id, limit \\ 10) do
    from(r in AcademicRecord,
      where: r.student_id == ^student_id,
      order_by: [desc: r.recorded_date],
      limit: ^limit
    )
    |> Repo.all()
    |> Repo.preload(:discipline)
  end
end
