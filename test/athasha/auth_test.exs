defmodule Athasha.AuthTest do
  use Athasha.DataCase

  alias Athasha.Auth

  import Athasha.Auth.Tools

  describe "auth" do
    alias Athasha.Auth.User

    test "create_user/1 with valid data creates a user" do
      user = %{
        email: "some@guy.com",
        name: "Some Guy",
        password: encrypt("Secret"),
        origin: "127.0.0.1",
        confirmed: true
      }

      assert {:ok, %User{} = user} = Auth.create_user(user)
      assert user.email == "some@guy.com"
      assert user.name == "Some Guy"
      assert user.password == encrypt("Secret")
      assert user.origin == "127.0.0.1"
      assert user.confirmed == true
    end
  end
end
