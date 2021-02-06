defmodule AthashaWeb.AuthControllerResetInvalidTest do
  use AthashaWeb.ConnCase

  alias Athasha.Repo

  alias Athasha.Auth
  alias Athasha.Auth.User
  alias Athasha.Auth.Token
  alias Athasha.Auth.Email

  import Athasha.Auth.Tools
  import Athasha.Auth.TestTools

  describe "auth controller reset invalid input - " do
    test "reset post rejects non existing email", %{conn: conn} do
      user_params = %{
        email: "some@guy.com",
        password: "Secret"
      }

      [] = Repo.all(User)

      conn = post(conn, Routes.auth_path(conn, :reset_post), user: user_params)
      assert html_response(conn, 200) =~ "Email not found."
      assert html_response(conn, 200) =~ ~s(value="some@guy.com")
      assert get_flash(conn, :error) == "Email not found."
      assert Repo.all(Token) == []
      assert Repo.all(Email) == []
    end

    test "reset post rejects blank password", %{conn: conn} do
      %User{
        email: "some@guy.com",
        name: "Some Guy",
        password: encrypt("Secret"),
        origin: "127.0.0.1",
        confirmed: false
      }
      |> create_user!()

      user_params = %{
        email: "some@guy.com",
        password: " \t\n\r"
      }

      conn = post(conn, Routes.auth_path(conn, :reset_post), user: user_params)
      assert html_response(conn, 200) =~ "Password cannot be blank."
      assert html_response(conn, 200) =~ ~s(value="some@guy.com")
      assert get_flash(conn, :error) == "Password cannot be blank."
      assert Repo.all(Token) == []
      assert Repo.all(Email) == []
    end

    test "reset apply rejects expired reset token", %{conn: conn} do
      %User{
        email: "some@guy.com",
        name: "Some Guy",
        password: encrypt("Secret"),
        origin: "127.0.0.1",
        confirmed: false
      }
      |> create_user!()

      [user] = Repo.all(User)

      token =
        %Token{
          origin: "127.0.0.1",
          token: "SomeToken",
          payload: encrypt("OtherSecret"),
          user_id: user.id,
          expired: true
        }
        |> Auth.create_token!()

      conn = get(conn, Routes.auth_path(conn, :reset_apply, id: user.id, token: token.token))
      assert redirected_to(conn) == Routes.auth_path(conn, :signin_get)
      assert get_flash(conn, :error) == "Your token has expired."

      [user] = Repo.all(User)
      assert user.confirmed == false
      assert user.password == encrypt("Secret")
    end
  end
end
