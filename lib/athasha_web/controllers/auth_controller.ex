defmodule AthashaWeb.AuthController do
  use AthashaWeb, :controller

  alias Athasha.Auth
  alias Athasha.Auth.User
  alias Athasha.Auth.Token
  alias Athasha.Auth.Email
  alias Athasha.Auth.Session

  def signup_get(conn, _params) do
    changeset = Auth.change_user(%User{})
    action = Routes.auth_path(conn, :signup_post)
    render(conn, "signup.html", changeset: changeset, action: action)
  end

  def signup_post(conn, %{"user" => user_params}) do
    user_params =
      user_params
      |> Map.put("origin", origin(conn))
      |> Map.put("password", encrypt(user_params))

    case Auth.create_user(user_params) do
      {:ok, user} ->
        token =
          %Token{}
          |> Map.put(:user_id, user.id)
          |> Map.put(:token, Ecto.UUID.generate())
          |> Map.put(:origin, user.origin)

        token |> Auth.create_token!()

        base_url = Routes.auth_url(conn, :confirm_email)
        confirm_url = "#{base_url}?id=#{token.user_id}&token=#{token.token}"

        %Email{}
        |> Map.put(:email, user.email)
        |> Map.put(:title, "Athasha - Confirm your email to complete sign up")
        |> Map.put(:body, """
        <b>Follow link below to complete sign up</b>
        <p><a href="#{confirm_url}">#{base_url}</a></p>
        """)
        |> Auth.create_email!()

        # should not redirect to referer because referer
        # most likely will redirect back to signin
        conn
        |> put_flash(
          :info,
          """
            Account created successfully.
            Check your inbox to confirm your email before signing in.
          """
        )
        |> redirect(to: Routes.auth_path(conn, :signin_get))

      {:error, %Ecto.Changeset{} = changeset} ->
        action = Routes.auth_path(conn, :signup_post)
        render(conn, "signup.html", changeset: changeset, action: action)
    end
  end

  def signin_get(conn, _params) do
    changeset = Auth.change_user(%User{})
    action = Routes.auth_path(conn, :signin_post)
    render(conn, "signin.html", changeset: changeset, action: action)
  end

  def signin_post(conn, %{"user" => user_params}) do
    user_params = user_params |> Map.put("password", encrypt(user_params))

    case Auth.find_user_by_credentials(user_params) do
      user = %User{} ->
        %Session{}
        |> Map.put(:name, user.name)
        |> Map.put(:email, user.name)
        |> Map.put(:origin, origin(conn))
        |> Auth.create_session!()

        conn
        |> put_flash(:info, "Successful sign in")
        |> redirect(to: referer(conn))

      _ ->
        changeset = Auth.change_user(%User{}, user_params)
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

        # go home if referer is signin or signup
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

  defp origin(conn) do
    forwarded_for = List.first(Plug.Conn.get_req_header(conn, "x-forwarded-for"))

    if forwarded_for do
      String.split(forwarded_for, ",")
      |> Enum.map(&String.trim/1)
      |> List.first()
    else
      to_string(:inet_parse.ntoa(conn.remote_ip))
    end
  end

  defp encrypt(%{"password" => password}) do
    case String.trim(password) do
      "" -> ""
      _ -> :crypto.hash(:sha256, password) |> Base.encode16()
    end
  end
end
