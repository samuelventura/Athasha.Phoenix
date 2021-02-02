defmodule Athasha.AuthTest do
  use Athasha.DataCase

  alias Athasha.Auth

  describe "users" do
    alias Athasha.Auth.User

    test "create_user/1 with valid data creates a user" do
      user = %{
        email: "some email",
        name: "some name",
        password: "some password",
        origin: "some origin"
      }

      assert {:ok, %User{} = user} = Auth.create_user(user)
      assert user.email == "some email"
      assert user.name == "some name"
      assert user.password == "some password"
      assert user.origin == "some origin"
    end
  end
end
