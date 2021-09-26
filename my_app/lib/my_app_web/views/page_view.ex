defmodule MyAppWeb.PageView do
  use MyAppWeb, :view

  def region do
    MyApp.Fly.Region.current() || "REGION NOT SET"
  end
end
