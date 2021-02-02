defmodule Athasha.AuthTest do
  use Athasha.DataCase

  alias Athasha.Auth

  describe "users" do
    alias Athasha.Auth.User

    @valid_attrs %{
      email: "some email",
      name: "some name",
      password: "some password",
      origin: "some origin"
    }
    @update_attrs %{
      email: "some updated email",
      name: "some updated name",
      password: "some updated password",
      origin: "some updated origin"
    }
    @invalid_attrs %{email: nil, name: nil, password: nil, origin: nil}

    def user_fixture(attrs \\ %{confirmed: false}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Auth.create_user()

      user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Auth.create_user(@valid_attrs)
      assert user.email == "some email"
      assert user.name == "some name"
      assert user.password == "some password"
      assert user.origin == "some origin"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Auth.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Auth.update_user(user, @update_attrs)
      assert user.email == "some updated email"
      assert user.name == "some updated name"
      assert user.password == "some updated password"
      assert user.origin == "some updated origin"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Auth.update_user(user, @invalid_attrs)
      assert user == Auth.get_user_by_id(user.id)
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Auth.change_user(user)
    end
  end
end
