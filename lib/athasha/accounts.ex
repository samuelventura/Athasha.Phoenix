defmodule Athasha.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Athasha.Repo

  alias Athasha.Accounts.User
  alias Athasha.Accounts.Session

  @doc false
  def list_users do
    Repo.all(User)
  end

  @doc false
  def get_user!(id), do: Repo.get!(User, id)

  @doc false
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc false
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc false
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc false
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  def find_user_by_credentials(%{"email" => email, "password" => password}) do
    User
    |> where([u], u.email == ^email)
    |> where([u], u.password == ^password)
    |> where([u], u.confirmed)
    |> Repo.one()
  end

  def create_session!(attrs \\ %{}) do
    %Session{}
    |> Session.changeset(attrs)
    |> Repo.insert!()
  end
end
