defmodule MatchWatch.Repo do
  use Ecto.Repo,
    otp_app: :match_watch,
    adapter: Ecto.Adapters.Postgres
end
