defmodule FireblocksSdk.Api.GasStation do
  alias FireblocksSdk.Schema

  import FireblocksSdk.Request

  @doc """
  Returns gas station settings and ETH balance.
  """
  def get_settings() do
    get!("/v1/gas_station")
  end

  @doc """
  Returns gas station settings and balances for a requested asset.
  """
  def get_settings_by_asset(asset) when is_binary(asset) do
    get!("/v1/gas_station/#{asset}")
  end

  @doc """
  Configures gas station settings for ETH or given asset.

  Options:\n#{NimbleOptions.docs(Schema.gas_station_settings_request())}
  """
  def update_settings(config, idempotentKey \\ "") do
    {:ok, options} = NimbleOptions.validate(config, Schema.gas_station_settings_request())

    path =
      case options[:assetId] do
        nil -> "/v1/gas_station/config"
        asset_id -> "/v1/gas_station/config/#{asset_id}"
      end

    params =
      options
      |> Keyword.delete(:assetId)
      |> Jason.encode!()

    put!(path, params, idempotentKey)
  end
end
