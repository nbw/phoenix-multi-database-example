defmodule MyApp.Repo do
  use Ecto.Repo,
    otp_app: :my_app,
    adapter: Ecto.Adapters.Postgres

  alias MyApp.Repo.Replicas
  defdelegate replica(), to: Replicas
end
