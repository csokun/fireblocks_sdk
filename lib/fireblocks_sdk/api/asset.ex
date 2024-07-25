defmodule FireblocksSdk.Api.Asset do
  import FireblocksSdk.Request

  @assets_path "/v1/assets"

  @register_asset_schema [
    blockchainId: [type: :string, require: true],
    address: [type: :string, require: true],
    symbol: [type: :string, require: true]
  ]

  @update_asset_price_schema [
    assetId: [type: :string, require: true],
    currency: [type: :string, require: true],
    price: [type: {:or, [:integer, :float]}, require: true]
  ]

  @doc """
  Register a new asset to a workspace and return the newly created asset's details. Currently supported chains are:

  - EVM based chains
  - Stellar
  - Algorand
  - TRON
  - NEAR
  - Solana

  ```
    FireblocksSdk.Api.Asset.register([
      blockchainId: "ETH_TEST3",
      address: "0xe7A9as1oa38bc4da0248s179E30aa94CcF453991",
      symbol: "TST3"
    ])
  ```

  Options: \n#{NimbleOptions.docs(@register_asset_schema)}
  """
  def register(asset, idempotent_key \\ "") do
    {:ok, params} = NimbleOptions.validate(asset, @register_asset_schema)
    post!("#{@assets_path}", Jason.encode!(params), idempotent_key)
  end

  @doc """
  Set asset price for the given asset id. Returns the asset price response.

  ```
    FireblocksSdk.Api.Asset.register([
      assetId: "ETH_TEST3",
      currency: "USD",
      price: 1000
    ])
  ```

  Options: \n#{NimbleOptions.docs(@update_asset_price_schema)}
  """
  def set_price(price, idempotent_key \\ "") do
    {:ok, options} = NimbleOptions.validate(price, @update_asset_price_schema)

    params =
      options
      |> Keyword.delete(:assetId)
      |> Jason.encode!()

    post!("#{@assets_path}/prices/#{params[:assetId]}", params, idempotent_key)
  end
end
