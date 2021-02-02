defmodule Athasha.Auth do
  @moduledoc """
  The Auth context.
  """

  import Ecto.Query, warn: false
  alias Athasha.Repo

  alias Athasha.Auth.User
  alias Athasha.Auth.Token
  alias Athasha.Auth.Email
  alias Athasha.Auth.Session

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

  def create_token!(%Token{} = token) do
    token
    |> Token.changeset(%{})
    |> Repo.insert!()
  end

  def get_user_by_id(id) do
    Repo.get_by(User, id: id)
  end

  def get_user_by_email(email) do
    Repo.get_by(User, email: email)
  end

  def get_valid_token(token, user_id) do
    Repo.get_by(Token, token: token, user_id: user_id, done: false)
  end

  @doc false
  def update_token(%Token{} = token, attrs) do
    token
    |> Token.changeset(attrs)
    |> Repo.update()
  end

  def create_email!(%Email{} = email) do
    email
    |> Email.changeset(%{})
    |> Repo.insert!()
  end

  def get_user_by_credentials(email, password) do
    User
    |> where([u], u.email == ^email)
    |> where([u], u.password == ^password)
    |> where([u], u.confirmed)
    |> Repo.one()
  end

  def create_session!(%Session{} = session) do
    session
    |> Session.changeset(%{})
    |> Repo.insert!()
  end
end
