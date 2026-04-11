defmodule FireblocksSdk.Api.EmbeddedWallet do
  @moduledoc """
  Embedded Wallets (NCW) API module for Fireblocks SDK.
  """

  import FireblocksSdk.Request

  @base_path "/v1/ncw/wallets"

  @ncw_support_assets [
    pageCursor: [type: :string, doc: "Next page cursor to fetch"],
    pageSize: [type: :integer, doc: "Items per page", default: 200],
    onlyBaseAssets: [type: :boolean, default: true, doc: "Only base assets"]
  ]

  @doc """
  Retrieve supported assets for Non-Custodial Wallets.

  Options:\n#{NimbleOptions.docs(@ncw_support_assets)}
  """
  def get_supported_assets(opts \\ []) do
    {:ok, params} = NimbleOptions.validate(opts, @ncw_support_assets)
    # GET /ncw/wallets/supported_assets
    # opts: pageCursor, pageSize, onlyBaseAssets
    query_string = URI.encode_query(params)
    get!("#{@base_path}/supported_assets?#{query_string}")
  end

  @ncw_list_wallet [
    pageCursor: [type: :string, doc: "Next page cursor to fetch"],
    pageSize: [type: :integer, doc: "Items per page", default: 200],
    onlyBaseAssets: [type: :boolean, default: true, doc: "Only base assets"],
    sort: [
      type: {:in, [:createdAt]},
      default: :createdAt,
      doc: "Field(s) to use for sorting"
    ],
    order: [
      type: {:in, [:asc, :desc]},
      default: :asc,
      doc: " Is the order ascending or decending"
    ]
  ]

  @doc """
  List all Non-Custodial Wallets.

  Options:\n#{NimbleOptions.docs(@ncw_list_wallet)}
  """
  def list_wallets(opts \\ []) do
    {:ok, params} = NimbleOptions.validate(opts, @ncw_list_wallet)
    # GET /ncw/wallets
    # opts: pageCursor, pageSize, sort, order, enabled
    query_string =
      params
      |> atom_to_string([:sort])
      |> atom_to_upper([:order])
      |> URI.encode_query()

    get!("#{@base_path}?#{query_string}")
  end

  @doc """
  Get a wallet by its ID.
  """
  def get_wallet(wallet_id) do
    # GET /ncw/wallets/{walletId}
    get!("#{@base_path}/#{wallet_id}")
  end

  @doc """
  Create a new account under a specific Non-Custodial Wallet.
  """
  def create_account(wallet_id, opts \\ [], idempotency_key \\ "") do
    # POST /ncw/wallets/{walletId}/accounts
    # opts: account creation params
    post!("#{@base_path}/#{wallet_id}/accounts", Jason.encode!(opts), idempotency_key)
  end

  @doc """
  Get an account by wallet and account ID.
  """
  def get_account(wallet_id, account_id) do
    # GET /ncw/wallets/{walletId}/accounts/{accountId}
    get!("#{@base_path}/#{wallet_id}/accounts/#{account_id}")
  end

  @doc """
  Retrieve asset by wallet, account, and asset ID.
  """
  def get_asset(wallet_id, account_id, asset_id) do
    # GET /ncw/wallets/{walletId}/accounts/{accountId}/assets/{assetId}
    get!("#{@base_path}/#{wallet_id}/accounts/#{account_id}/assets/#{asset_id}")
  end

  @doc """
  Refresh asset balance for a wallet/account/asset.
  """
  def refresh_asset_balance(wallet_id, account_id, asset_id, opts \\ []) do
    # PUT /ncw/wallets/{walletId}/accounts/{accountId}/assets/{assetId}/balance
    put!(
      "#{@base_path}/#{wallet_id}/accounts/#{account_id}/assets/#{asset_id}/balance",
      Jason.encode!(opts)
    )
  end

  @doc """
  Get addresses for a wallet/account/asset.
  """
  def get_addresses(wallet_id, account_id, asset_id, opts \\ []) do
    # GET /ncw/wallets/{walletId}/accounts/{accountId}/assets/{assetId}/addresses
    query_string = URI.encode_query(opts)

    get!(
      "#{@base_path}/#{wallet_id}/accounts/#{account_id}/assets/#{asset_id}/addresses?#{query_string}"
    )
  end

  @doc """
  Get latest backup details for a wallet.
  """
  def get_latest_backup(wallet_id) do
    # GET /ncw/wallets/{walletId}/backup/latest
    get!("#{@base_path}/#{wallet_id}/backup/latest")
  end

  @doc """
  Get embedded wallet device details.
  """
  def get_device(wallet_id, device_id) do
    # GET /ncw/wallets/{walletId}/devices/{deviceId}
    get!("#{@base_path}/#{wallet_id}/devices/#{device_id}")
  end

  @doc """
  Get device key setup state.
  """
  def get_device_setup_status(wallet_id, device_id) do
    # GET /ncw/wallets/{walletId}/devices/{deviceId}/setup_status
    get!("#{@base_path}/#{wallet_id}/devices/#{device_id}/setup_status")
  end

  @doc """
  Get the public key for a derivation path.
  """
  def get_public_key_info(wallet_id, opts \\ []) do
    # GET /ncw/wallets/{walletId}/public_key_info
    query_string = URI.encode_query(opts)
    get!("#{@base_path}/#{wallet_id}/public_key_info?#{query_string}")
  end

  @doc """
  Get the public key of an asset (with change/addressIndex).
  """
  def get_asset_public_key_info(
        wallet_id,
        account_id,
        asset_id,
        change,
        address_index,
        opts \\ []
      ) do
    # GET /ncw/wallets/{walletId}/accounts/{accountId}/assets/{assetId}/{change}/{addressIndex}/public_key_info
    query_string = URI.encode_query(opts)

    get!(
      "#{@base_path}/#{wallet_id}/accounts/#{account_id}/assets/#{asset_id}/#{change}/#{address_index}/public_key_info?#{query_string}"
    )
  end

  @doc """
  Get the public key of an asset (alternate path).
  """
  def get_asset_public_key_info_alt(
        wallet_id,
        account_id,
        asset_id,
        change,
        address_index,
        opts \\ []
      ) do
    # GET /ncw/{walletId}/accounts/{accountId}/{assetId}/{change}/{addressIndex}/public_key_info
    query_string = URI.encode_query(opts)

    get!(
      "/v1/ncw/#{wallet_id}/accounts/#{account_id}/#{asset_id}/#{change}/#{address_index}/public_key_info?#{query_string}"
    )
  end
end
