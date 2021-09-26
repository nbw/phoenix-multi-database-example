import Config

if config_env() == :prod do
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  app_name =
    System.get_env("FLY_APP_NAME") ||
      raise "FLY_APP_NAME not available"

  config :my_app, MyAppWeb.Endpoint,
    server: true,
    url: [host: "#{app_name}.fly.dev", port: 80],
    http: [
      port: String.to_integer(System.get_env("PORT") || "4000"),
      # IMPORTANT: support IPv6 addresses
      transport_options: [socket_opts: [:inet6]]
    ],
    secret_key_base: secret_key_base

  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  # Main DB
  config :my_app, MyApp.Repo,
    url: database_url,
    # IMPORTANT: Or it won't find the DB server
    socket_options: [:inet6],
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

  # Define read-replica regions (not including the primary)
  regions = ["ord", "ams", "atl", "syd"]

  # Create Repo modules for each region
  # Ex:
  # %{
  #    "ord" => MyApp.Repo.Ord
  #    "amd" => MyApp.Repo.Amd
  #  }
  replicas =
    Enum.reduce(regions, %{}, fn region, acc ->
      replica = Module.concat(MyApp.Repo, String.capitalize(region))
      Map.put(acc, region, replica)
    end)

  # Replicas Config
  config :my_app, MyApp.Repo.Replicas, replicas: replicas

  # Configure each replica
  for {region, repo} = a <- replicas do
    # Add region to the hostname
    {_, opts} =
      Ecto.Repo.Supervisor.parse_url(database_url)
      |> Keyword.get_and_update!(:hostname, fn hostname -> {hostname, "#{region}.#{hostname}"} end)

    # Replica's use the port 5433
    opts = Keyword.replace!(opts, :port, 5433)

    opts =
      opts ++
        [
          socket_options: [:inet6],
          pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")
        ]

    config :my_app, repo, opts
  end
end
