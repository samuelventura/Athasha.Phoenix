defmodule AthashaWeb.AuthControllerSignupValidTest do
  use AthashaWeb.ConnCase

  alias Athasha.Repo

  alias Athasha.Auth
  alias Athasha.Auth.User
  alias Athasha.Auth.Token
  alias Athasha.Auth.Email

  import Athasha.Auth.Tools
  import Athasha.Auth.TestTools

  describe "auth controller signup valid input - " do
    test "signup get renders form", %{conn: conn} do
      conn = get(conn, Routes.auth_path(conn, :signup_get))
      assert html_response(conn, 200) =~ "<h1>Sign up</h1>"
    end

    test "signup post creates user, token, and email", %{conn: conn} do
      user_params = %{
        email: "some@guy.com",
        name: "Some Guy",
        password: "Secret"
      }

      conn = post(conn, Routes.auth_path(conn, :signup_post), user: user_params)
      assert redirected_to(conn) == Routes.auth_path(conn, :signin_get)
      assert get_flash(conn, :info) =~ "Account created successfully."

      [user] = Repo.all(User)
      assert user.name == "Some Guy"
      assert user.email == "some@guy.com"
      assert user.origin == "127.0.0.1"
      assert user.password == encrypt("Secret")
      assert user.confirmed == false

      [token] = Repo.all(Token)
      assert token.origin == "127.0.0.1"
      assert token.expired == false
      assert token.payload == nil
      assert trimmed_length(token.token) == 36
      assert token.user_id == user.id

      [email] = Repo.all(Email)
      assert email.email == "some@guy.com"
      assert email.title == "Athasha - Confirm your email to complete sign up"
      assert email.sent == false
      assert email.body =~ Routes.auth_url(conn, :signup_apply)
      assert email.body =~ "?id=#{token.user_id}&token=#{token.token}"
    end

    test "signup apply confirms user email", %{conn: conn} do
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
          user_id: user.id
        }
        |> Auth.create_token!()

      conn = get(conn, Routes.auth_path(conn, :signup_apply, id: user.id, token: token.token))
      assert redirected_to(conn) == Routes.auth_path(conn, :signin_get)
      assert get_flash(conn, :info) == "Your email has been confirmed."

      [user] = Repo.all(User)
      assert user.name == "Some Guy"
      assert user.email == "some@guy.com"
      assert user.origin == "127.0.0.1"
      assert user.password == encrypt("Secret")
      assert user.confirmed == true

      [token] = Repo.all(Token)
      assert token.origin == "127.0.0.1"
      assert token.expired == true
      assert token.payload == nil
      assert token.token == "SomeToken"
      assert token.user_id == user.id
    end
  end
end
