defmodule Tower2slack.Server do

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

        Map.merge(@defaults, payload)
          |> Map.put(:channel, channel)
          |> deliver(slack_url)

        conn |> send_resp(200, "ok")
      _ ->
        conn |> send_resp(200, "^^")
    end
  end

  defp tower_header(conn, name) do
    conn |> get_req_header("x-tower-#{name}") |> List.first
  end
  
end
