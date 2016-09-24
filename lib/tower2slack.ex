defmodule Tower2slack do

  import Supervisor.Spec
  
  def start(:normal, args) do
    worker(__MODULE__, [args])
      |> Supervisor.start_link(strategy: :one_for_one)
  end

  def start_link(args) do
    Plug.Adapters.Cowboy.http(Tower2slack.Server, [], args)
  end

end
