defmodule FireblocksSdk do
  import FireblocksSdk.Request

  @moduledoc """
  Un-official Fireblocks Elixir API Client. For full API spec visit [https://docs.fireblocks.com/api/swagger-ui](https://docs.fireblocks.com/api/swagger-ui).

  ```
  # config/dev.exs
  config :fireblocks_sdk,
    apiKey: "",
    apiSecret: \"\"\"
    -----BEGIN RSA PRIVATE KEY-----
    --api-secret-key-goes-here--
    -----END RSA PRIVATE KEY-----
    \"\"\"
  ```
  """

  @doc """
  Gets all assets that are currently supported by Fireblocks

  ```
  iex> FireblocksSdk.get_supported_assets()
  ```
  """
  def get_supported_assets(), do: get("/v1/supported_assets")

  @doc """
  List all users for the workspace.

  Please note that this endpoint is available only for API keys with Admin permissions.
  """
  def get_users(), do: get!("/v1/users")

  def estimate_network_fee(asset_id) when is_binary(asset_id),
    do: get!("/v1/estimate_network_fee?assetId=#{asset_id}")

  @doc """
  Get audit logs by day.
  """
  def audits(:day), do: get!("/v1/audits?timePeriod=DAY")
  def audits(:week), do: get!("/v1/audits?timePeriod=WEEK")
end
