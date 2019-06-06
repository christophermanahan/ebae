use Mix.Config

# Configure your database
config :ebae, Ebae.Repo,
  username: "postgres",
  password: "postgres",
  database: "ebae_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :exq,
  host: System.get_env("REDIS_HOST") || "localhost",
  port: System.get_env("REDIS_PORT") || 6379

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ebae, EbaeWeb.Endpoint,
  http: [port: 4002],
  server: false

config :ebae, Ebae.Accounts.Guardian,
  issuer: "ebae",
  secret_key: "r/Syflh2VFEkCAAbul9UjVk5fXFmnJ044UBN/7Fa9syZwxkhF7k3e9ph0cVC0VSm"

config :argon2_elixir,
  t_cost: 1,
  m_cost: 8

config :ebae, Ebae.Mailer,
  adapter: Bamboo.TestAdapter

# Print only warnings and errors during test
config :logger, level: :warn
