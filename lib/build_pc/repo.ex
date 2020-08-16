defmodule BuildPc.Repo do
  use Ecto.Repo,
    otp_app: :build_pc,
    adapter: Ecto.Adapters.Postgres
end
