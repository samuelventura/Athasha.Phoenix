defmodule AthashaWeb.AuthControllerSigninInvalidTest do
  use AthashaWeb.ConnCase

  alias Athasha.Repo

  alias Athasha.Auth.User
  alias Athasha.Auth.Session

  import Athasha.Auth.Tools

  describe "auth controller signin invalid input - " do
    test "signin post rejects non existing email", %{conn: conn} do
      user_params = %{
        email: "some@guy.com",
        password: "Secret"
      }

      [] = Repo.all(User)

      conn = post(conn, Routes.auth_path(conn, :signin_post), user: user_params)
      assert html_response(conn, 200) =~ ~s(action="#{Routes.auth_path(conn, :signin_post)}")
      assert html_response(conn, 200) =~ "Invalid credentials."
      assert html_response(conn, 200) =~ ~s(value="some@guy.com")
      assert get_flash(conn, :error) == "Invalid credentials."
      assert Repo.all(Session) == []
    end

    test "signin post rejects unconfirmed email", %{conn: conn} do
      %User{
        email: "some@guy.com",
        name: "Some Guy",
        password: encrypt("Secret"),
        origin: "127.0.0.1",
        confirmed: false
      }
      |> Repo.insert!()

      [user] = Repo.all(User)

      user_params = %{
        email: user.email,
        password: user.password
      }

      conn = post(conn, Routes.auth_path(conn, :signin_post), user: user_params)
      assert html_response(conn, 200) =~ ~s(action="#{Routes.auth_path(conn, :signin_post)}")
      assert html_response(conn, 200) =~ "Invalid credentials."
      assert html_response(conn, 200) =~ ~s(value="some@guy.com")
      assert get_flash(conn, :error) == "Invalid credentials."
      assert Repo.all(Session) == []
    end

    test "signin post rejects password mismatch", %{conn: conn} do
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
        password: "OtherSecret"
      }

      conn = post(conn, Routes.auth_path(conn, :signin_post), user: user_params)
      assert html_response(conn, 200) =~ ~s(action="#{Routes.auth_path(conn, :signin_post)}")
      assert html_response(conn, 200) =~ "Invalid credentials."
      assert html_response(conn, 200) =~ ~s(value="some@guy.com")
      assert get_flash(conn, :error) == "Invalid credentials."
      assert Repo.all(Session) == []
    end
  end
end
