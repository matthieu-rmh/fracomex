defmodule Fracomex.Repo do
  use Ecto.Repo,
    otp_app: :fracomex,
    adapter: Ecto.Adapters.Postgres
end
