defmodule AthashaWeb.AuthController do
  use AthashaWeb, :controller

  alias Athasha.Accounts
  alias Athasha.Accounts.User

  def signup_get(conn, _params) do
    changeset = Accounts.change_user(%User{})
    action = Routes.auth_path(conn, :signup_post)
    render(conn, "signup.html", changeset: changeset, action: action)
  end

  def signup_post(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        changeset = Accounts.change_user(user)
        action = Routes.auth_path(conn, :signin_post)

        # signups should no redirect to referer because referer
        # most likely will redirect back to signin
        conn
        |> put_flash(
          :info,
          """
            Account created successfully.
            Check your inbox to confirm your email before signing in.
          """
        )
        |> render("signin.html", changeset: changeset, action: action)

      {:error, %Ecto.Changeset{} = changeset} ->
        action = Routes.auth_path(conn, :signup_post)
        render(conn, "signup.html", changeset: changeset, action: action)
    end
  end

  def signin_get(conn, _params) do
    changeset = Accounts.change_user(%User{})
    action = Routes.auth_path(conn, :signin_post)
    render(conn, "signin.html", changeset: changeset, action: action)
  end

  def signin_post(conn, %{"user" => user_params}) do
    case Accounts.find_user_by_credentials(user_params) do
      _user = %User{} ->
        conn
        |> put_flash(:info, "Successful sign in")
        |> redirect(to: referer(conn))

      _ ->
        changeset = Accounts.change_user(%User{}, user_params)
        action = Routes.auth_path(conn, :signin_post)

        conn
        |> put_flash(:error, "Invalid credentials")
        |> render("signin.html", changeset: changeset, action: action)
    end
  end

  defp referer(conn) do
    case Plug.Conn.get_req_header(conn, "referer") do
      [url | _] ->
        referer =
          url
          |> URI.parse()
          |> Map.get(:path)

        # go home is referer is signin or signup
        case Enum.member?(
               [Routes.auth_path(conn, :signin_get), Routes.auth_path(conn, :signup_get)],
               referer
             ) do
          true -> Routes.page_path(conn, :index)
          false -> referer
        end

      _ ->
        Routes.page_path(conn, :index)
    end
  end
end
