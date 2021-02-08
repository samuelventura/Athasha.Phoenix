defmodule AthashaWeb.AuthControllerResetValidTest do
  use AthashaWeb.ConnCase

  alias Athasha.Repo

  alias Athasha.Auth.User
  alias Athasha.Auth.Token
  alias Athasha.Auth.Email

  import Athasha.Auth.Tools

  describe "auth controller reset valid input - " do
    test "reset get renders form", %{conn: conn} do
      conn = get(conn, Routes.auth_path(conn, :reset_get))
      assert html_response(conn, 200) =~ "<h1>Reset password</h1>"
    end

    test "reset post creates token and email", %{conn: conn} do
      user =
        %User{
          email: "some@guy.com",
          name: "Some Guy",
          password: encrypt("Secret"),
          origin: "127.0.0.1",
          confirmed: true
        }
        |> Repo.insert!()

      user_params = %{
        email: "some@guy.com",
        password: "OtherSecret"
      }

      conn = post(conn, Routes.auth_path(conn, :reset_post), user: user_params)
      assert redirected_to(conn) == Routes.auth_path(conn, :signin_get)
      assert get_flash(conn, :info) =~ "Reset link created successfuly."

      [token] = Repo.all(Token)
      assert token.origin == "127.0.0.1"
      assert token.expired == false
      assert token.payload == encrypt("OtherSecret")
      assert trimmed_length(token.token) == 36
      assert token.user_id == user.id

      [email] = Repo.all(Email)
      assert email.email == "some@guy.com"
      assert email.title == "Athasha - Confirm your password reset request"
      assert email.sent == false
      assert email.body =~ Routes.auth_url(conn, :reset_apply)
      assert email.body =~ "?id=#{token.user_id}&token=#{token.token}"
    end

    test "reset apply resets password and confirms user", %{conn: conn} do
      user =
        %User{
          email: "some@guy.com",
          name: "Some Guy",
          password: encrypt("Secret"),
          origin: "127.0.0.1",
          confirmed: false
        }
        |> Repo.insert!()

      token =
        %Token{
          origin: "127.0.0.1",
          token: "SomeToken",
          payload: encrypt("OtherSecret"),
          user_id: user.id
        }
        |> Repo.insert!()

      conn = get(conn, Routes.auth_path(conn, :reset_apply, id: user.id, token: token.token))
      assert redirected_to(conn) == Routes.auth_path(conn, :signin_get)
      assert get_flash(conn, :info) == "Your password has been reset."

      [user] = Repo.all(User)
      assert user.name == "Some Guy"
      assert user.email == "some@guy.com"
      assert user.origin == "127.0.0.1"
      assert user.password == encrypt("OtherSecret")
      assert user.confirmed == true

      [token] = Repo.all(Token)
      assert token.origin == "127.0.0.1"
      assert token.expired == true
      assert token.payload == encrypt("OtherSecret")
      assert token.token == "SomeToken"
      assert token.user_id == user.id
    end
  end
end
