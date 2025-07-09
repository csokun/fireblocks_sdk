defmodule FireblocksSdk.Api.Asset do
  import FireblocksSdk.Request

  @assets_path "/v1/assets"

  @register_asset_schema [
    blockchainId: [type: :string, required: true],
    address: [type: :string, required: true],
    symbol: [type: :string, required: true]
  ]

  @update_asset_price_schema [
    assetId: [type: :string, required: true],
    currency: [type: :string, required: true],
    price: [type: {:or, [:integer, :float]}, required: true]
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
    FireblocksSdk.Api.Asset.set_price([
      assetId: "USD1_B75VRLGX_TQL4",
      currency: "USD",
      price: 1000
    ])
  ```

  Options: \n#{NimbleOptions.docs(@update_asset_price_schema)}
  """
  def set_price(opts, idempotent_key \\ "") do
    {:ok, options} = NimbleOptions.validate(opts, @update_asset_price_schema)
    assetId = Keyword.get(opts, :assetId)

    params =
      options
      |> Keyword.delete(:assetId)
      |> Enum.into(%{})
      |> Jason.encode!()

    post!("#{@assets_path}/prices/#{assetId}", params, idempotent_key)
  end
end
