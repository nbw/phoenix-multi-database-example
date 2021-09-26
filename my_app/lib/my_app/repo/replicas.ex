defmodule MyApp.Repo.Replicas do
  @moduledoc """
  Handles all replica related tasks
  """

  @type region() :: String.t()
  @type replica() :: module()

  @doc """
  Returns a Map of replica module names with
  """
  @spec replicas() :: %{region() => replica()}
  def replicas, do: Application.get_env(:my_app, __MODULE__)[:replicas] || %{}

  @doc """
  Returns a list of regions configured in runtime.exs
  """
  @spec regions() :: [region()]
  def regions, do: Map.keys(replicas())

  @doc """
  Helper method for returning a list of replica modules
  """
  @spec list_replicas() :: [replica()]
  def list_replicas, do: Map.values(replicas())

  @doc """
  Returns a Repo for the current region
  """
  @spec replica() :: module()
  def replica() do
    MyApp.Fly.Region.current()
    |> replica()
  end

  @doc """
  Returns a Repo for the a given region, returns primary Repo as a default
  """
  @spec replica(region()) :: module()
  def replica(region) do
    if Enum.member?(regions(), region) do
      replicas()[region]
    else
      MyApp.Repo
    end
  end

  @doc """
  Generate Repo modules for each replica
  """
  def compile_replicas do
    for replica <- list_replicas() do
      defmodule replica do
        use Ecto.Repo,
          otp_app: :my_app,
          adapter: Ecto.Adapters.Postgres,
          read_only: true
      end
    end
  end
end
