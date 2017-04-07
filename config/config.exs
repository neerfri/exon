use Mix.Config

config :exon, Exon.TestApp.EctoRepo,
  adapter: Ecto.Adapters.Postgres,
  database: "exon_test_app",
  hostname: "localhost",
  username: "postgres",
  password: "postgres"
