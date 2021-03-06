defmodule AthashaWeb.Router do
  use AthashaWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :livepipe do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {AthashaWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AthashaWeb do
    pipe_through :browser

    get "/auth/signup", AuthController, :signup_get
    post "/auth/signup", AuthController, :signup_post
    get "/auth/email", AuthController, :signup_apply
    get "/auth/signin", AuthController, :signin_get
    post "/auth/signin", AuthController, :signin_post
    get "/auth/reset", AuthController, :reset_get
    post "/auth/reset", AuthController, :reset_post
    get "/auth/password", AuthController, :reset_apply
    get "/auth/signout", AuthController, :signout_get
  end

  scope "/", AthashaWeb do
    pipe_through :livepipe

    live "/", PageLive, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", AthashaWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: AthashaWeb.Telemetry
    end
  end
end
