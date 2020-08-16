use Mix.Config

# Configure your database
config :build_pc, BuildPc.Repo,
  username: "postgres",
  password: "postgres",
  database: "build_pc_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :build_pc, BuildPcWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
