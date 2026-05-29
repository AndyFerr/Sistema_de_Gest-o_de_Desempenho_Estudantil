defmodule AcademicPerformance.Context.Users do
  import Ecto.Query
  alias AcademicPerformance.Repo
  alias AcademicPerformance.Schemas.User

  def list_users do
    Repo.all(User)
  end

  def list_teachers do
    from(u in User, where: u.role == :teacher)
    |> Repo.all()
  end

  def list_managers do
    from(u in User, where: u.role == :manager)
    |> Repo.all()
  end

  def get_user!(id), do: Repo.get!(User, id)

  def get_user_by_email(email) do
    Repo.get_by(User, email: email)
  end

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def get_user_with_disciplines(user_id) do
    User
    |> Repo.get(user_id)
    |> Repo.preload(teacher_disciplines: :discipline)
  end
end
