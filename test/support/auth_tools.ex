defmodule Athasha.Auth.TestTools do
  alias Athasha.Repo
  alias Athasha.Auth.User

  def create_user!(%User{} = user) do
    user
    |> User.changeset(%{})
    |> Repo.insert!()
  end
end
