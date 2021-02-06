defmodule AthashaWeb.AuthControllerSigninValidTest do
  use AthashaWeb.ConnCase

  alias Athasha.Repo

  alias Athasha.Auth.User
  alias Athasha.Auth.Session

  import Athasha.Auth.Tools
  import Athasha.Auth.TestTools

  describe "auth controller signin valid input - " do
    test "signin get renders form", %{conn: conn} do
      conn = get(conn, Routes.auth_path(conn, :signin_get))
      assert html_response(conn, 200) =~ "<h1>Sign in</h1>"
    end

    test "signin post creates session", %{conn: conn} do
      user =
        %User{
          email: "some@guy.com",
          name: "Some Guy",
          password: encrypt("Secret"),
          origin: "127.0.0.1",
          confirmed: true
        }
        |> create_user!()

      user_params = %{
        email: "some@guy.com",
        password: "Secret"
      }

      conn = post(conn, Routes.auth_path(conn, :signin_post), user: user_params)
      assert redirected_to(conn) == Routes.page_path(conn, :index)
      assert get_flash(conn, :info) == "Successful sign in."

      [session] = Repo.all(Session)
      assert session.email == "some@guy.com"
      assert session.name == "Some Guy"
      assert session.origin == "127.0.0.1"
      assert session.user_id == user.id
      assert get_session(conn, :session_id) == session.id
    end

    test "signout get clears session", %{conn: conn} do
      conn = init_test_session(conn, %{session_id: 1})
      assert get_session(conn, :session_id) == 1
      conn = get(conn, Routes.auth_path(conn, :signout_get))
      assert redirected_to(conn) == Routes.page_path(conn, :index)
      assert get_session(conn, :session_id) == nil
      assert get_flash(conn, :info) == "Successful sign out."
    end
  end
end
