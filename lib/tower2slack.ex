defmodule Tower2slack do

  @moduledoc """
  提供一个 HTTP 服务, 处理 [Tower.im](https://tower.im) 的 hook 数据，并转发给 Slack.
  """

  alias Tower2slack.Server
  alias Plug.Adapters.Cowboy

  import Supervisor.Spec

  def start(:normal, args) do
    [worker(__MODULE__, [args])]
      |> Supervisor.start_link(strategy: :one_for_one)
  end

  def start_link(args) do
    Cowboy.http(Server, [], args)
  end

end
