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

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def update_user!(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update!()
  end

  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  def get_user_by_id(id) do
    Repo.get_by(User, id: id)
  end

  def get_user_by_email(email) do
    Repo.get_by(User, email: email)
  end

  def get_pending_token(token, user_id) do
    Repo.get_by(Token, token: token, user_id: user_id, expired: false)
  end

  def get_confirmed_user_by_credentials(email, password) do
    Repo.get_by(User, email: email, password: password, confirmed: true)
  end

  def create_email!(%Email{} = email) do
    email
    |> Email.changeset(%{})
    |> Repo.insert!()
  end

  def create_token!(%Token{} = token) do
    token
    |> Token.changeset(%{})
    |> Repo.insert!()
  end

  def update_token!(%Token{} = token, attrs) do
    token
    |> Token.changeset(attrs)
    |> Repo.update!()
  end

  def create_session!(%Session{} = session) do
    session
    |> Session.changeset(%{})
    |> Repo.insert!()
  end
end
