defmodule Fracomex.EbpRepo do
  use Ecto.Repo,
    otp_app: :fracomex,
    adapter: Ecto.Adapters.Tds
end
