use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :danmaku_api, DanmakuApi.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :danmaku_api, DanmakuApi.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "danmaku_api_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
