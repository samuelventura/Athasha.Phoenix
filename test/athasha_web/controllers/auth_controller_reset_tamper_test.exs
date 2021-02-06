defmodule AthashaWeb.AuthControllerResetTamperTest do
  use AthashaWeb.ConnCase

  alias Athasha.Repo

  alias Athasha.Auth
  alias Athasha.Auth.User
  alias Athasha.Auth.Token

  import Athasha.Auth.Tools
  import Athasha.Auth.TestTools

  describe "auth controller reset tampered input - " do
    test "reset apply rejects unexisting user", %{conn: conn} do
      user =
        %User{
          email: "some@guy.com",
          name: "Some Guy",
          password: encrypt("Secret"),
          origin: "127.0.0.1",
          confirmed: false
        }
        |> create_user!()

      token =
        %Token{
          origin: "127.0.0.1",
          token: "SomeToken",
          payload: encrypt("OtherSecret"),
          user_id: user.id,
          expired: true
        }
        |> Auth.create_token!()

      conn = get(conn, Routes.auth_path(conn, :reset_apply, id: 0, token: token.token))
      assert redirected_to(conn) == Routes.auth_path(conn, :signin_get)
      assert get_flash(conn, :error) == "Your token has expired."

      [user] = Repo.all(User)
      assert user.confirmed == false
      assert user.password == encrypt("Secret")
    end

    test "reset apply rejects unexisting token", %{conn: conn} do
      user =
        %User{
          email: "some@guy.com",
          name: "Some Guy",
          password: encrypt("Secret"),
          origin: "127.0.0.1",
          confirmed: false
        }
        |> create_user!()

      conn = get(conn, Routes.auth_path(conn, :reset_apply, id: user.id, token: "SomeToken"))
      assert redirected_to(conn) == Routes.auth_path(conn, :signin_get)
      assert get_flash(conn, :error) == "Your token has expired."

      [user] = Repo.all(User)
      assert user.confirmed == false
      assert user.password == encrypt("Secret")
    end
  end
end
