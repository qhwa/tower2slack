defmodule Tower2slack.Server do

  require Logger
  import Plug.Conn

  @slack_host "https://hooks.slack.com"

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

        channel = tower_header(conn, "signature")
        target = case channel do
          "#" <> _ -> [channel: channel]
          "@" <> _ -> [channel: channel]
          _ -> nil
        end

        body
          |> Poison.decode!
          |> Tower2slack.Proxy.forward(tower_header(conn, "event"), slack_url, target)

        conn |> send_resp(200, "ok")
      _ ->
        conn |> send_resp(200, "^^")
    end
  end

  defp tower_header(conn, name) do
    conn |> get_req_header("x-tower-#{name}") |> List.first
  end
  
end
