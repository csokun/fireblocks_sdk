import Config

config :joken,
  current_time_adapter: Joken.CurrentTime.OS

import_config "#{Mix.env()}.exs"
