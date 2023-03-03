import Config

config :fireblocks_sdk,
  apiKey: "---this-is-my-key---",
  apiSecret: ""

config :joken,
  current_time_adapter: Joken.CurrentTime.OS

import_config "#{Mix.env()}.exs"
