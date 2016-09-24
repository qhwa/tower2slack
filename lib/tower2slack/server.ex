defmodule Tower2slack.Server do

  @moduledoc """
  提供一个 HTTP 服务，将收到的数据交给核心处理。
  并将转换后的数据发送的对应的 Slack hook 地址。
  Slack hook 地址是根据当前 url 推算出来的，只是
  替换了当前的域名.
  """

  require Logger
  import Plug.Conn
  import Tower2slack.Proxy, only: [transform_tower: 2, deliver: 2]

  @slack_host "https://hooks.slack.com"

  @defaults %{
    icon_url: "https://tower.im/assets/mobile/icon/icon@512-84fa5f6ced2a1bd53a409013f739b7ba.png"
  }


  def init(opts) do
    opts
  end

  def call(conn, _opts) do

    Logger.info  fn -> "[#{conn.method}] #{conn.request_path}" end
    Logger.debug fn -> "receive connection: #{inspect conn}" end

    case conn.path_info do
      ["services" | parts] ->
        slack_url      = Enum.join([@slack_host, "services" | parts], "/")
        {:ok, body, _} = conn |> read_body

        Logger.debug fn -> body end

        channel = tower_header(conn, "signature") || "#general"

        payload = body
          |> Poison.decode!
          |> transform_tower(tower_header(conn, "event"))

        @defaults
          |> Map.merge(payload)
          |> Map.put(:channel, channel)
          |> deliver(slack_url)

        send_resp(conn, 200, "ok")

      _ ->
        send_resp(conn, 200, "^^")
    end
  end

  defp tower_header(conn, name) do
    conn
      |> get_req_header("x-tower-#{name}")
      |> List.first
  end

end
