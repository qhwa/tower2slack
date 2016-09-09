use Mix.Config

config :tower2slack, :deliver_opts, [
  # {:proxy, {"YOUR_PROXY_HOST", YOUR_PROXY_PORT}},
  recv_timeout: 10000,
  timeout: 200000
]
