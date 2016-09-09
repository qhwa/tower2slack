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
        evt_type       = conn |> get_req_header("x-tower-event") |> List.first
        slack_url      = Enum.join([@slack_host, "services" | parts], "/")
        {:ok, body, _} = conn |> read_body
        body
          |> Poison.decode!
          |> Tower2slack.Proxy.forward(evt_type, slack_url)

        conn |> send_resp(200, "ok")
      _ ->
        conn |> send_resp(200, "^^")
    end
  end
  
end
