defmodule FireblocksSdk.Api.GasStation do
  import FireblocksSdk.Request

  @base_path "/v1/gas_station"

  @doc """
  Returns gas station settings and ETH balance.
  """
  def get_settings(), do: get!(@base_path)

  @doc """
  Returns gas station settings and balances for a requested asset.

  ```
  FireblocksSdk.Api.GasStation.get_settings_by_asset("ETH")
  ```

  Options:
    - `asset`: `String.t()`
  """
  def get_settings_by_asset(asset) when is_binary(asset) do
    get!("#{@base_path}/#{asset}")
  end

  @update_settings_schema [
    gasThreshold: [type: :string, required: true],
    gasCap: [type: :string, required: true],
    maxGasPrice: [type: :string],
    assetId: [type: :string]
  ]

  @doc """
  Configures gas station settings for ETH or given asset.

  ```
  FireblocksSdk.Api.GasStation.update_settings([
    assetId: "ETH",
    gasThreshold: "0.005",
    gasCap: "0.003"
  ])
  ```

  Options:\n#{NimbleOptions.docs(@update_settings_schema)}
  """
  def update_settings(config, idempotentKey \\ "") do
    {:ok, options} = NimbleOptions.validate(config, @update_settings_schema)

    path =
      case options[:assetId] do
        nil -> "#{@base_path}/config"
        asset_id -> "#{@base_path}/config/#{asset_id}"
      end

    params =
      options
      |> Keyword.delete(:assetId)
      |> Jason.encode!()

    put!(path, params, idempotentKey)
  end
end
