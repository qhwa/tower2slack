defmodule Tower2slack do
  
  def start(:normal, _args) do
    Plug.Adapters.Cowboy.http(Tower2slack.Server, [])
  end

end
