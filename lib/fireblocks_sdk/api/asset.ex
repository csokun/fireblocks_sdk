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

  @list_assets [
    blockchainId: [type: :string, doc: "Blockchain id of the assets"],
    assetClass: [type: :string],
    symbol: [type: :string],
    scope: [type: {:in, [:global, :local]}],
    deprecated: [type: :boolean],
    ids: [type: {:list, :string}, doc: "A list of blockchain IDs (max 100)"],
    pageCursor: [type: :string, doc: "Page cursor to fetch"],
    pageSize: [type: :non_neg_integer, doc: "Items per page (max 500)"]
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

  @doc """
  Retrieves all assets supported by Fireblocks in your workspace, providing extended information and enhanced performance compared to the legacy supported_assets endpoint.

  Options: \n#{NimbleOptions.docs(@list_assets)}
  """
  def list(opt \\ []) do
    {:ok, params} = NimbleOptions.validate(opt, @list_assets)

    query_string =
      params
      |> atom_to_upper([:scope])
      |> URI.encode_query()
      |> case do
        "" -> ""
        value -> "?" <> value
      end

    get!("#{@assets_path}#{query_string}")
  end

  @doc """
  Returns an asset by ID or legacyID.
  """
  def get(assetId) when is_bitstring(assetId) do
    get!("#{@assets_path}/#{assetId}")
  end
end
