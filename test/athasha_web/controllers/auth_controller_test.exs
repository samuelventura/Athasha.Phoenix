defmodule AthashaWeb.AuthControllerTest do
  use AthashaWeb.ConnCase

  alias Athasha.Repo

  alias Athasha.Auth
  alias Athasha.Auth.User
  alias Athasha.Auth.Token
  alias Athasha.Auth.Email
  alias Athasha.Auth.Session

  describe "successful authentication" do
    test "signup form renders", %{conn: conn} do
      conn = get(conn, Routes.auth_path(conn, :signup_get))
      assert html_response(conn, 200) =~ "Sign up</button>"
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
      assert token.done == false
      assert token.payload == nil
      assert trimlen(token.token) == 36
      assert token.user_id == user.id

      [email] = Repo.all(Email)
      assert email.email == "some@guy.com"
      assert email.title == "Athasha - Confirm your email to complete sign up"
      assert email.sent == false
      assert email.body =~ Routes.auth_url(conn, :signup_apply)
      assert email.body =~ "id=#{token.user_id}&token=#{token.token}"
    end

    test "signup email gets confirmed", %{conn: conn} do
      user = %User{
        email: "some@guy.com",
        name: "Some Guy",
        password: "Secret",
        origin: "127.0.0.1"
      }

      user = create_user!(user)

      token = %Token{
        origin: "127.0.0.1",
        token: "abcdefg",
        user_id: user.id
      }

      token = Auth.create_token!(token)

      conn = get(conn, Routes.auth_path(conn, :signup_apply, id: user.id, token: token.token))
      assert redirected_to(conn) == Routes.auth_path(conn, :signin_get)
      assert get_flash(conn, :info) == "Your email has been confirmed"

      [user] = Repo.all(User)
      assert user.name == "Some Guy"
      assert user.email == "some@guy.com"
      assert user.origin == "127.0.0.1"
      assert user.password == "Secret"
      assert user.confirmed == true

      [token] = Repo.all(Token)
      assert token.origin == "127.0.0.1"
      assert token.done == true
      assert token.payload == nil
      assert trimlen(token.token) == 7
      assert token.user_id == user.id
    end

    test "signin form renders", %{conn: conn} do
      conn = get(conn, Routes.auth_path(conn, :signin_get))
      assert html_response(conn, 200) =~ "Reset password</a>"
      assert html_response(conn, 200) =~ "Sign in</button>"
    end

    test "signin post creates session", %{conn: conn} do
      user = %User{
        email: "some@guy.com",
        name: "Some Guy",
        password: encrypt("Secret"),
        origin: "127.0.0.1",
        confirmed: true
      }

      create_user!(user)

      user_params = %{
        email: "some@guy.com",
        password: "Secret"
      }

      conn = post(conn, Routes.auth_path(conn, :signin_post), user: user_params)
      assert redirected_to(conn) == Routes.page_path(conn, :index)
      assert get_flash(conn, :info) =~ "Successful sign in"

      [session] = Repo.all(Session)
      assert session.email == "some@guy.com"
      assert session.name == "Some Guy"
      assert session.origin == "127.0.0.1"
    end

    test "reset form renders", %{conn: conn} do
      conn = get(conn, Routes.auth_path(conn, :reset_get))
      assert html_response(conn, 200) =~ "Sign in</a>"
      assert html_response(conn, 200) =~ "Reset</button>"
    end

    test "reset post creates token and email", %{conn: conn} do
      user = %User{
        email: "some@guy.com",
        name: "Some Guy",
        password: encrypt("Secret"),
        origin: "127.0.0.1",
        confirmed: true
      }

      user = create_user!(user)

      user_params = %{
        email: "some@guy.com",
        password: "OtherSecret"
      }

      conn = post(conn, Routes.auth_path(conn, :reset_post), user: user_params)
      assert redirected_to(conn) == Routes.auth_path(conn, :signin_get)
      assert get_flash(conn, :info) =~ "Reset link created successfuly."

      [token] = Repo.all(Token)
      assert token.origin == "127.0.0.1"
      assert token.done == false
      assert token.payload == encrypt("OtherSecret")
      assert trimlen(token.token) == 36
      assert token.user_id == user.id

      [email] = Repo.all(Email)
      assert email.email == "some@guy.com"
      assert email.title == "Athasha - Confirm your password reset request"
      assert email.sent == false
      assert email.body =~ Routes.auth_url(conn, :reset_apply)
      assert email.body =~ "id=#{token.user_id}&token=#{token.token}"
    end

    test "password gets reset", %{conn: conn} do
      user = %User{
        email: "some@guy.com",
        name: "Some Guy",
        password: encrypt("Secret"),
        origin: "127.0.0.1"
      }

      user = create_user!(user)

      token = %Token{
        origin: "127.0.0.1",
        token: "abcdefg",
        payload: encrypt("OtherSecret"),
        user_id: user.id
      }

      token = Auth.create_token!(token)

      conn = get(conn, Routes.auth_path(conn, :reset_apply, id: user.id, token: token.token))
      assert redirected_to(conn) == Routes.auth_path(conn, :signin_get)
      assert get_flash(conn, :info) == "Your password has been reset"

      [user] = Repo.all(User)
      assert user.name == "Some Guy"
      assert user.email == "some@guy.com"
      assert user.origin == "127.0.0.1"
      assert user.password == encrypt("OtherSecret")
      assert user.confirmed == true

      [token] = Repo.all(Token)
      assert token.origin == "127.0.0.1"
      assert token.done == true
      assert token.payload == encrypt("OtherSecret")
      assert trimlen(token.token) == 7
      assert token.user_id == user.id
    end
  end

  defp create_user!(%User{} = user) do
    user
    |> User.changeset(%{})
    |> Repo.insert!()
  end

  defp encrypt(password) do
    :crypto.hash(:sha256, password) |> Base.encode16()
  end

  defp trimlen(text) do
    text |> String.trim() |> String.length()
  end
end
