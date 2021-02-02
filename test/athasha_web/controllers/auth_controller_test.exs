defmodule AthashaWeb.AuthControllerTest do
  use AthashaWeb.ConnCase

  alias Athasha.Repo

  alias Athasha.Auth.User
  alias Athasha.Auth.Token
  alias Athasha.Auth.Email
  
  describe "signup" do

    test "shows signup page", %{conn: conn} do
      conn = get(conn, Routes.auth_path(conn, :signup_get))
      assert html_response(conn, 200) =~ "Sign up</button>"
    end

    test "successful signup", %{conn: conn} do
      user_params = %{
        email: "a@b.com", 
        name: "A B", 
        password: "ab"}
      conn = post(conn, Routes.auth_path(conn, :signup_post), user: user_params)
      assert redirected_to(conn) == Routes.auth_path(conn, :signin_get)
      [user] = Repo.all(User)
      assert user.name == "A B"
      assert user.email == "a@b.com"
      assert user.origin == "127.0.0.1"
      assert user.password == encrypt("ab")
      assert user.confirmed == false 
      [token] = Repo.all(Token)
      assert token.origin == "127.0.0.1"
      assert token.done == false
      assert token.payload == nil
      assert String.length(token.token) == 36
      assert token.user_id == user.id
      [email] = Repo.all(Email)
      assert email.email == "a@b.com"
      assert email.title == "Athasha - Confirm your email to complete sign up"
      assert email.sent == false
      assert email.body =~ "id=#{token.user_id}&token=#{token.token}"
    end
  end

  defp encrypt(password) do
    :crypto.hash(:sha256, password) |> Base.encode16()
  end

end
