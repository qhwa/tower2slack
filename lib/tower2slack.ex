defmodule Tower2slack do
  
  def start(:normal, args) do
    Plug.Adapters.Cowboy.http(Tower2slack.Server, [], args)
  end

end
