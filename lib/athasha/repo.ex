defmodule Athasha.Repo do
  use Ecto.Repo,
    otp_app: :athasha,
    adapter: Ecto.Adapters.Postgres
end
