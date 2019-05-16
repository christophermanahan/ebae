# In this file, we load production configuration and
# secrets from environment variables. You can also
# hardcode secrets, although such is generally not
# recommended and you have to remember to add this
# file to your .gitignore.
use Mix.Config

database_url =
  System.get_env("DATABASE_URL") ||
    IO.puts("""
    environment variable DATABASE_URL is missing.
    For example: ecto://USER:PASS@HOST/DATABASE
    """)

config :ebae, Ebae.Repo,
  # ssl: true,
  url: database_url,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    IO.puts("""
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """)

config :ebae, EbaeWeb.Endpoint,
  http: [:inet6, port: String.to_integer(System.get_env("PORT") || "4000")],
  secret_key_base: secret_key_base

guardian_secret_key =
  System.get_env("GUARDIAN_SECRET_KEY") ||
    IO.puts("""
    environment variable GUARDIAN_SECRET_KEY is missing.
    You can generate one by calling: mix guardian.gen.secret
    """)

config :ebae, Ebae.Accounts.Guardian,
  issuer: "ebae",
  secret_key: guardian_secret_key
