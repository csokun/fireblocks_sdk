defmodule FireblocksSdk.Api.InternalWallet do
  alias FireblocksSdk.Schema

  import FireblocksSdk.Request

  @base_path "/v1/internal_wallets"

  @doc """
  Gets a list of internal wallets.

  Note: BTC-based assets belonging to whitelisted addresses cannot be retrieved between 00:00 UTC and 00:01 UTC daily due to third-party provider, Blockchair, being unavailable for this 60 second period. Please wait until the next minute to retrieve BTC-based assets.
  """
  def get_wallets() do
    get!(@base_path)
  end

  @doc """
  Returns all assets in an internal wallet by ID.
  """
  def get_wallet(wallet_id) when is_binary(wallet_id) do
    get!("#{@base_path}/#{wallet_id}")
  end

  @doc """
  Get an asset from internal wallet.
  """
  def get_wallet_asset(wallet_id, asset_id) do
    get!("#{@base_path}/#{wallet_id}/#{asset_id}")
  end

  @doc """
  Creates a new internal wallet with the requested name.

  Options:\n#{NimbleOptions.docs(Schema.wallet_create_request())}
  """
  def create(wallet, idempotentKey \\ "") do
    {:ok, options} = NimbleOptions.validate(wallet, Schema.wallet_create_request())
    data = options |> Jason.encode!()
    post!(@base_path, data, idempotentKey)
  end

  @doc """
  Deletes an internal wallet by ID.
  """
  def remove(wallet_id) when is_binary(wallet_id) do
    delete!("#{@base_path}/#{wallet_id}")
  end

  @doc """
  Add asset to internal wallet.

  Options:\n#{NimbleOptions.docs(Schema.wallet_set_customer_ref_id_request())}
  """
  def add_asset(asset_info, idempotentKey \\ "") do
    {:ok, options} = NimbleOptions.validate(asset_info, Schema.wallet_add_asset_request())
    wallet_id = options[:walletId]
    asset_id = options[:assetId]

    data =
      options
      |> Keyword.delete(:walletId)
      |> Keyword.delete(:assetId)
      |> Jason.encode!()

    post!("#{@base_path}/#{wallet_id}/#{asset_id}", data, idempotentKey)
  end

  @doc """
  Deletes a whitelisted address (for an asset) from an internal wallet.
  """
  def remove_asset(wallet_id, asset_id) do
    delete!("#{@base_path}/#{wallet_id}/#{asset_id}")
  end

  @doc """
  Sets an AML/KYT customer reference ID for the specific internal wallet.
  """
  def set_customer_ref_id(reference, idempotentKey \\ "") do
    {:ok, options} =
      NimbleOptions.validate(reference, Schema.wallet_set_customer_ref_id_request())

    wallet_id = options[:walletId]

    data = %{customerRefId: options[:customerRefId]} |> Jason.encode!()
    post!("#{@base_path}/#{wallet_id}/set_customer_ref_id", data, idempotentKey)
  end
end
