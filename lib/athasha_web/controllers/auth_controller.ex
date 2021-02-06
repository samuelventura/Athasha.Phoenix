defmodule AthashaWeb.AuthController do
  use AthashaWeb, :controller

  alias Athasha.Auth
  alias Athasha.Auth.User
  alias Athasha.Auth.Token
  alias Athasha.Auth.Email
  alias Athasha.Auth.Session

  import Athasha.Auth.Tools

  def signup_get(conn, _params) do
    changeset = Auth.change_user(%User{})
    action = Routes.auth_path(conn, :signup_post)
    render(conn, "signup.html", changeset: changeset, action: action)
  end

  def signup_post(conn, %{"user" => user_params}) do
    password =
      user_params
      |> Map.get("password", "")
      |> encrypt_ifn_blank()

    user_params =
      user_params
      |> Map.put("origin", origin(conn))
      |> Map.put("password", password)
      |> Map.put("confirmed", false)

    case Auth.create_user(user_params) do
      {:ok, user} ->
        token =
          %Token{}
          |> Map.put(:user_id, user.id)
          |> Map.put(:token, Ecto.UUID.generate())
          |> Map.put(:origin, user.origin)
          |> Auth.create_token!()

        base_url = Routes.auth_url(conn, :signup_apply)
        confirm_url = "#{base_url}?id=#{token.user_id}&token=#{token.token}"

        %Email{}
        |> Map.put(:email, user.email)
        |> Map.put(:title, "Athasha - Confirm your email to complete sign up")
        |> Map.put(:body, """
        <b>Follow link below to complete sign up</b>
        <p><a href="#{confirm_url}">Confirm your email to complete sign up</a></p>
        """)
        |> Auth.create_email!()

        # should not redirect to referer because referer
        # most likely will redirect back to signin
        conn
        |> put_flash(:info, """
        Account created successfully.
        Check your inbox to confirm your email before signing in.
        <p><a href="#{confirm_url}">Confirm your email to complete sign up</a></p>
        """)
        |> redirect(to: Routes.auth_path(conn, :signin_get))

      {_, changeset} ->
        action = Routes.auth_path(conn, :signup_post)

        conn
        |> put_flash(:error, "Check data validation errors.")
        |> render("signup.html", changeset: changeset, action: action)
    end
  end

  def signup_apply(conn, %{"id" => user_id, "token" => token}) do
    user = Auth.get_user_by_id(user_id)
    token = Auth.get_pending_token(token, user_id)

    case [user, token] do
      [%User{}, %Token{}] ->
        Auth.update_user!(user, %{confirmed: true})
        Auth.update_token!(token, %{expired: true})

        conn
        |> put_flash(:info, "Your email has been confirmed.")
        |> redirect(to: Routes.auth_path(conn, :signin_get))

      _ ->
        conn
        |> put_flash(:error, "Your token has expired.")
        |> redirect(to: Routes.auth_path(conn, :signin_get))
    end
  end

  def signin_get(conn, _params) do
    changeset = Auth.change_user(%User{})
    action = Routes.auth_path(conn, :signin_post)
    render(conn, "signin.html", changeset: changeset, action: action)
  end

  def signin_post(conn, %{"user" => user_params}) do
    %{"email" => email, "password" => password} = user_params
    password = encrypt_ifn_blank(password)

    case Auth.get_confirmed_user_by_credentials(email, password) do
      user = %User{} ->
        session =
          %Session{}
          |> Map.put(:user_id, user.id)
          |> Map.put(:name, user.name)
          |> Map.put(:email, user.email)
          |> Map.put(:origin, origin(conn))
          |> Auth.create_session!()

        conn
        |> put_session(:session_id, session.id)
        |> put_flash(:info, "Successful sign in.")
        |> redirect(to: referer(conn))

      _ ->
        changeset = Auth.change_user(%User{}, user_params)
        action = Routes.auth_path(conn, :signin_post)

        conn
        |> put_flash(:error, "Invalid credentials.")
        |> render("signin.html", changeset: changeset, action: action)
    end
  end

  def reset_get(conn, _params) do
    changeset = Auth.change_user(%User{})
    action = Routes.auth_path(conn, :reset_post)
    render(conn, "reset.html", changeset: changeset, action: action)
  end

  def reset_post(conn, %{"user" => user_params}) do
    %{"email" => email, "password" => password} = user_params
    password = encrypt_ifn_blank(password)
    pwdlen = String.length(password)

    case {pwdlen, Auth.get_user_by_email(email)} do
      {64, user = %User{}} ->
        token =
          %Token{}
          |> Map.put(:user_id, user.id)
          |> Map.put(:token, Ecto.UUID.generate())
          |> Map.put(:origin, origin(conn))
          |> Map.put(:payload, password)
          |> Auth.create_token!()

        base_url = Routes.auth_url(conn, :reset_apply)
        confirm_url = "#{base_url}?id=#{token.user_id}&token=#{token.token}"

        %Email{}
        |> Map.put(:email, user.email)
        |> Map.put(:title, "Athasha - Confirm your password reset request")
        |> Map.put(:body, """
        <b>Follow link below to complete password reset</b>
        <p><a href="#{confirm_url}">Confirm your password reset request</a></p>
        """)
        |> Auth.create_email!()

        conn
        |> put_flash(:info, """
        Reset link created successfuly.
        Check your inbox to confirm your reset before signing in.
        <p><a href="#{confirm_url}">Confirm your password reset request</a></p>
        """)
        |> redirect(to: Routes.auth_path(conn, :signin_get))

      {0, _} ->
        changeset = Auth.change_user(%User{}, user_params)
        action = Routes.auth_path(conn, :signin_post)

        conn
        |> put_flash(:error, "Password cannot be blank.")
        |> render("reset.html", changeset: changeset, action: action)

      {64, _} ->
        changeset = Auth.change_user(%User{}, user_params)
        action = Routes.auth_path(conn, :signin_post)

        conn
        |> put_flash(:error, "Email not found.")
        |> render("reset.html", changeset: changeset, action: action)
    end
  end

  def reset_apply(conn, %{"id" => user_id, "token" => token}) do
    user = Auth.get_user_by_id(user_id)
    token = Auth.get_pending_token(token, user_id)

    case [user, token] do
      [%User{}, %Token{}] ->
        Auth.update_user!(user, %{confirmed: true, password: token.payload})
        Auth.update_token!(token, %{expired: true})

        conn
        |> put_flash(:info, "Your password has been reset.")
        |> redirect(to: Routes.auth_path(conn, :signin_get))

      _ ->
        conn
        |> put_flash(:error, "Your token has expired.")
        |> redirect(to: Routes.auth_path(conn, :signin_get))
    end
  end

  def signout_get(conn, _params) do
    conn
    |> delete_session(:session_id)
    |> put_flash(:info, "Successful sign out.")
    |> redirect(to: Routes.page_path(conn, :index))
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
end
