defmodule AthashaWeb.AuthControllerSignupInvalidTest do
  use AthashaWeb.ConnCase

  alias Athasha.Repo

  alias Athasha.Auth.User
  alias Athasha.Auth.Token
  alias Athasha.Auth.Email

  import Athasha.Auth.Tools

  describe "auth controller signup invalid input - " do
    test "signup post rejects misformatted email", %{conn: conn} do
      user_params = %{
        email: "some@@guy.com",
        name: "Some Guy",
        password: "Secret"
      }

      [] = Repo.all(User)

      conn = post(conn, Routes.auth_path(conn, :signup_post), user: user_params)
      assert html_response(conn, 200) =~ ~s(action="#{Routes.auth_path(conn, :signup_post)}")
      assert html_response(conn, 200) =~ "Check data validation errors."
      assert html_response(conn, 200) =~ ~s(value="some@@guy.com")
      assert html_response(conn, 200) =~ ~s(value="Some Guy")
      assert html_response(conn, 200) =~ ~s("user_email">Invalid email address format)
      assert get_flash(conn, :error) == "Check data validation errors."
      assert length(Repo.all(User)) == 0
    end

    test "signup post rejects blank password", %{conn: conn} do
      user_params = %{
        email: "some@guy.com",
        name: "Some Guy",
        password: " \t\n\r"
      }

      [] = Repo.all(User)

      conn = post(conn, Routes.auth_path(conn, :signup_post), user: user_params)
      assert html_response(conn, 200) =~ ~s(action="#{Routes.auth_path(conn, :signup_post)}")
      assert html_response(conn, 200) =~ "Check data validation errors."
      assert html_response(conn, 200) =~ ~s(value="some@guy.com")
      assert html_response(conn, 200) =~ ~s(value="Some Guy")
      assert html_response(conn, 200) =~ ~s("user_password">Password cannot be blank)
      assert get_flash(conn, :error) == "Check data validation errors."
      assert length(Repo.all(User)) == 0
      assert Repo.all(Token) == []
      assert Repo.all(Email) == []
    end

    test "signup post rejects existing email", %{conn: conn} do
      %User{
        email: "some@guy.com",
        name: "Some Guy",
        password: encrypt("Secret"),
        origin: "127.0.0.1",
        confirmed: true
      }
      |> Repo.insert!()

      [user] = Repo.all(User)

      user_params = %{
        email: user.email,
        name: "Some Other Guy",
        password: "Secret"
      }

      conn = post(conn, Routes.auth_path(conn, :signup_post), user: user_params)
      assert html_response(conn, 200) =~ ~s(action="#{Routes.auth_path(conn, :signup_post)}")
      assert html_response(conn, 200) =~ "Check data validation errors."
      assert html_response(conn, 200) =~ ~s(value="some@guy.com")
      assert html_response(conn, 200) =~ ~s(value="Some Other Guy")
      assert html_response(conn, 200) =~ ~s("user_email">Email has already been taken)
      assert get_flash(conn, :error) == "Check data validation errors."
      assert length(Repo.all(User)) == 1
      assert Repo.all(Token) == []
      assert Repo.all(Email) == []
    end

    test "signup post rejects existing name", %{conn: conn} do
      %User{
        email: "some@guy.com",
        name: "Some Guy",
        password: encrypt("Secret"),
        origin: "127.0.0.1",
        confirmed: true
      }
      |> Repo.insert!()

      [user] = Repo.all(User)

      user_params = %{
        email: "other@guy.com",
        name: user.name,
        password: "Secret"
      }

      conn = post(conn, Routes.auth_path(conn, :signup_post), user: user_params)
      assert html_response(conn, 200) =~ ~s(action="#{Routes.auth_path(conn, :signup_post)}")
      assert html_response(conn, 200) =~ "Check data validation errors."
      assert html_response(conn, 200) =~ ~s(value="other@guy.com")
      assert html_response(conn, 200) =~ ~s(value="Some Guy")
      assert html_response(conn, 200) =~ ~s("user_name">Name has already been taken)
      assert get_flash(conn, :error) == "Check data validation errors."
      assert length(Repo.all(User)) == 1
      assert Repo.all(Token) == []
      assert Repo.all(Email) == []
    end

    test "signup post rejects existing name and email", %{conn: conn} do
      %User{
        email: "some@guy.com",
        name: "Some Guy",
        password: encrypt("Secret"),
        origin: "127.0.0.1",
        confirmed: true
      }
      |> Repo.insert!()

      [user] = Repo.all(User)

      user_params = %{
        email: user.email,
        name: user.name,
        password: "Secret"
      }

      # name check wins
      conn = post(conn, Routes.auth_path(conn, :signup_post), user: user_params)
      assert html_response(conn, 200) =~ ~s(action="#{Routes.auth_path(conn, :signup_post)}")
      assert html_response(conn, 200) =~ "Check data validation errors."
      assert html_response(conn, 200) =~ ~s(value="some@guy.com")
      assert html_response(conn, 200) =~ ~s(value="Some Guy")
      assert html_response(conn, 200) =~ ~s("user_name">Name has already been taken)
      assert get_flash(conn, :error) == "Check data validation errors."
      assert length(Repo.all(User)) == 1
      assert Repo.all(Token) == []
      assert Repo.all(Email) == []
    end

    test "signup apply rejects expired confirmation token", %{conn: conn} do
      %User{
        email: "some@guy.com",
        name: "Some Guy",
        password: encrypt("Secret"),
        origin: "127.0.0.1",
        confirmed: false
      }
      |> Repo.insert!()

      [user] = Repo.all(User)

      token =
        %Token{
          origin: "127.0.0.1",
          token: "SomeToken",
          user_id: user.id,
          expired: true
        }
        |> Repo.insert!()

      conn = get(conn, Routes.auth_path(conn, :signup_apply, id: user.id, token: token.token))
      assert redirected_to(conn) == Routes.auth_path(conn, :signin_get)
      assert get_flash(conn, :error) == "Your token has expired."

      [user] = Repo.all(User)
      assert user.confirmed == false
    end
  end
end
