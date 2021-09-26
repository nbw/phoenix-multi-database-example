defmodule MyApp.Fly.Region do
  @moduledoc """
  Helper module for Fly Regions

  [Fly Documenation](https://fly.io/docs/reference/regions/)
  """

  def current do
    System.fetch_env("FLY_REGION")
    |> case do
      {:ok, region} -> region
      _ -> nil
    end
  end
end
