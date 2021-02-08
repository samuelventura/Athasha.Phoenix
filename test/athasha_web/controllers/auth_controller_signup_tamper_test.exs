defmodule AthashaWeb.AuthControllerSignupTamperTest do
  use AthashaWeb.ConnCase

  alias Athasha.Repo

  alias Athasha.Auth.User
  alias Athasha.Auth.Token
  alias Athasha.Auth.Email

  import Athasha.Auth.Tools

  describe "auth controller signup tampered input - " do
    test "signup post rejects missing name", %{conn: conn} do
      user_params = %{email: "some@guy.com", password: "Secret"}
      conn = post(conn, Routes.auth_path(conn, :signup_post), user: user_params)
      assert html_response(conn, 200) =~ "Check data validation errors."
      assert get_flash(conn, :error) == "Check data validation errors."
      assert Repo.all(User) == []
      assert Repo.all(Token) == []
      assert Repo.all(Email) == []
    end

    test "signup post rejects missing email", %{conn: conn} do
      user_params = %{name: "Some Guy", password: "Secret"}
      conn = post(conn, Routes.auth_path(conn, :signup_post), user: user_params)
      assert html_response(conn, 200) =~ "Check data validation errors."
      assert get_flash(conn, :error) == "Check data validation errors."
      assert Repo.all(User) == []
      assert Repo.all(Token) == []
      assert Repo.all(Email) == []
    end

    test "signup post rejects missing password", %{conn: conn} do
      user_params = %{email: "some@guy.com", name: "Some Guy"}
      conn = post(conn, Routes.auth_path(conn, :signup_post), user: user_params)
      assert html_response(conn, 200) =~ "Check data validation errors."
      assert get_flash(conn, :error) == "Check data validation errors."
      assert Repo.all(User) == []
      assert Repo.all(Token) == []
      assert Repo.all(Email) == []
    end

    test "signup post rejects blank name", %{conn: conn} do
      user_params = %{email: "some@guy.com", name: " \t\r\n", password: "Secret"}
      conn = post(conn, Routes.auth_path(conn, :signup_post), user: user_params)
      assert html_response(conn, 200) =~ "Check data validation errors."
      assert get_flash(conn, :error) == "Check data validation errors."
      assert Repo.all(User) == []
      assert Repo.all(Token) == []
      assert Repo.all(Email) == []
    end

    test "signup post rejects blank email", %{conn: conn} do
      user_params = %{email: " \t\r\n", name: "Some Guy", password: "Secret"}
      conn = post(conn, Routes.auth_path(conn, :signup_post), user: user_params)
      assert html_response(conn, 200) =~ "Check data validation errors."
      assert get_flash(conn, :error) == "Check data validation errors."
      assert Repo.all(User) == []
      assert Repo.all(Token) == []
      assert Repo.all(Email) == []
    end

    test "signup post rejects blank password", %{conn: conn} do
      user_params = %{email: "some@guy.com", name: "Some Guy", password: " \t\r\n"}
      conn = post(conn, Routes.auth_path(conn, :signup_post), user: user_params)
      assert html_response(conn, 200) =~ "Check data validation errors."
      assert get_flash(conn, :error) == "Check data validation errors."
      assert Repo.all(User) == []
      assert Repo.all(Token) == []
      assert Repo.all(Email) == []
    end

    test "signup post replaces origin and confirmed", %{conn: conn} do
      user_params = %{
        email: "some@guy.com",
        name: "Some Guy",
        password: "Secret",
        origin: "SomeOrigin",
        confirmed: true
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
    end

    test "signup apply rejects unexisting user", %{conn: conn} do
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
          user_id: user.id,
          expired: true
        }
        |> Repo.insert!()

      conn = get(conn, Routes.auth_path(conn, :signup_apply, id: 0, token: token.token))
      assert redirected_to(conn) == Routes.auth_path(conn, :signin_get)
      assert get_flash(conn, :error) == "Your token has expired."

      [user] = Repo.all(User)
      assert user.confirmed == false
      assert user.password == encrypt("Secret")
    end

    test "signup apply rejects unexisting token", %{conn: conn} do
      user =
        %User{
          email: "some@guy.com",
          name: "Some Guy",
          password: encrypt("Secret"),
          origin: "127.0.0.1",
          confirmed: false
        }
        |> Repo.insert!()

      conn = get(conn, Routes.auth_path(conn, :signup_apply, id: user.id, token: "SomeToken"))
      assert redirected_to(conn) == Routes.auth_path(conn, :signin_get)
      assert get_flash(conn, :error) == "Your token has expired."

      [user] = Repo.all(User)
      assert user.confirmed == false
      assert user.password == encrypt("Secret")
    end
  end
end
