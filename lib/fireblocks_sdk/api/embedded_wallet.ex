defmodule FireblocksSdk.Api.EmbeddedWallet do
  @moduledoc """
  Embedded Wallets (NCW) API module for Fireblocks SDK.

  Implements all operations under the `/v1/ncw/wallets` base path as defined in
  the Fireblocks OpenAPI specification (tag: Embedded Wallets).
  """

  import FireblocksSdk.Request

  @base_path "/v1/ncw/wallets"

  # Shared pagination fields reused across multiple list endpoints.
  @pagination [
    pageCursor: [type: :string, doc: "Cursor to the next page of results"],
    pageSize: [
      type: :integer,
      doc: "Number of items per page (max 400)",
      default: 200
    ],
    order: [
      type: {:in, [:asc, :desc]},
      default: :asc,
      doc: "Sort direction: `:asc` or `:desc`"
    ]
  ]

  # ─── Supported Assets ──────────────────────────────────────────────────────

  @get_supported_assets_schema [
                                 onlyBaseAssets: [
                                   type: :boolean,
                                   default: true,
                                   doc: "When `true`, only base assets are returned"
                                 ]
                               ] ++ @pagination

  @doc """
  Retrieve all available supported assets for Non-Custodial Wallets.

  **operationId:** `GetEmbeddedWalletSupportedAssets`

  ## Options

  #{NimbleOptions.docs(@get_supported_assets_schema)}
  """
  @spec get_supported_assets(keyword()) :: map()
  def get_supported_assets(opts \\ []) do
    {:ok, params} = NimbleOptions.validate(opts, @get_supported_assets_schema)

    query_string =
      params
      |> atom_to_upper([:order])
      |> URI.encode_query()

    get!("#{@base_path}/supported_assets?#{query_string}")
  end

  # ─── Wallets ───────────────────────────────────────────────────────────────

  @list_wallets_schema [
                         sort: [
                           type: {:in, [:createdAt]},
                           default: :createdAt,
                           doc: "Field to sort by"
                         ],
                         enabled: [
                           type: :boolean,
                           doc: "When set, filters wallets by their enabled/disabled status"
                         ]
                       ] ++ @pagination

  @doc """
  List all Non-Custodial Wallets.

  **operationId:** `GetEmbeddedWallets`

  ## Options

  #{NimbleOptions.docs(@list_wallets_schema)}
  """
  @spec list_wallets(keyword()) :: map()
  def list_wallets(opts \\ []) do
    {:ok, params} = NimbleOptions.validate(opts, @list_wallets_schema)

    query_string =
      params
      |> atom_to_string([:sort])
      |> atom_to_upper([:order])
      |> URI.encode_query()

    get!("#{@base_path}?#{query_string}")
  end

  @doc """
  Create a new Non-Custodial Wallet.

  **operationId:** `CreateEmbeddedWallet`
  """
  @spec create_wallet(String.t()) :: map()
  def create_wallet(idempotency_key \\ "") do
    post!(@base_path, "", idempotency_key)
  end

  @doc """
  Get a Non-Custodial Wallet by its ID.

  **operationId:** `GetEmbeddedWallet`
  """
  @spec get_wallet(String.t()) :: map()
  def get_wallet(wallet_id) do
    get!("#{@base_path}/#{wallet_id}")
  end

  @update_wallet_status_schema [
    enabled: [
      type: :boolean,
      required: true,
      doc: "Whether the wallet should be enabled (`true`) or disabled (`false`)"
    ]
  ]

  @doc """
  Update the enabled/disabled status of a specific Non-Custodial Wallet.

  **operationId:** `updateEmbeddedWalletStatus`

  ## Options

  #{NimbleOptions.docs(@update_wallet_status_schema)}
  """
  @spec update_wallet_status(String.t(), keyword(), String.t()) :: map()
  def update_wallet_status(wallet_id, params, idempotency_key \\ "") do
    {:ok, params} = NimbleOptions.validate(params, @update_wallet_status_schema)
    data = params |> Enum.into(%{}) |> Jason.encode!()
    patch!("#{@base_path}/#{wallet_id}/status", data, idempotency_key)
  end

  @doc """
  Assign a specific Non-Custodial Wallet to a user.

  **operationId:** `assignEmbeddedWallet`
  """
  @spec assign_wallet(String.t(), String.t()) :: map()
  def assign_wallet(wallet_id, idempotency_key \\ "") do
    post!("#{@base_path}/#{wallet_id}/assign", "", idempotency_key)
  end

  @doc """
  Get the key setup state for a specific Non-Custodial Wallet, including
  required algorithms and device setup status.

  **operationId:** `getEmbeddedWalletSetupStatus`
  """
  @spec get_wallet_setup_status(String.t()) :: map()
  def get_wallet_setup_status(wallet_id) do
    get!("#{@base_path}/#{wallet_id}/setup_status")
  end

  # ─── Accounts ──────────────────────────────────────────────────────────────

  @doc """
  Create a new account under a specific Non-Custodial Wallet.

  **operationId:** `CreateEmbeddedWalletAccount`
  """
  @spec create_account(String.t(), String.t()) :: map()
  def create_account(wallet_id, idempotency_key \\ "") do
    post!("#{@base_path}/#{wallet_id}/accounts", "", idempotency_key)
  end

  @doc """
  Get a specific account under a specific Non-Custodial Wallet.

  **operationId:** `GetEmbeddedWalletAccount`
  """
  @spec get_account(String.t(), String.t()) :: map()
  def get_account(wallet_id, account_id) do
    get!("#{@base_path}/#{wallet_id}/accounts/#{account_id}")
  end

  # ─── Assets ────────────────────────────────────────────────────────────────

  @list_assets_schema [
                        sort: [
                          type: {:in, [:assetId, :createdAt]},
                          default: :assetId,
                          doc: "Field to sort by: `:assetId` or `:createdAt`"
                        ]
                      ] ++ @pagination

  @doc """
  Retrieve assets for a specific account under a specific Non-Custodial Wallet.

  **operationId:** `getEmbeddedWalletAssets`

  ## Options

  #{NimbleOptions.docs(@list_assets_schema)}
  """
  @spec list_assets(String.t(), String.t(), keyword()) :: map()
  def list_assets(wallet_id, account_id, opts \\ []) do
    {:ok, params} = NimbleOptions.validate(opts, @list_assets_schema)

    query_string =
      params
      |> atom_to_string([:sort])
      |> atom_to_upper([:order])
      |> URI.encode_query()

    get!("#{@base_path}/#{wallet_id}/accounts/#{account_id}/assets?#{query_string}")
  end

  @doc """
  Get a specific asset under a specific account within a Non-Custodial Wallet.

  **operationId:** `GetEmbeddedWalletAsset`
  """
  @spec get_asset(String.t(), String.t(), String.t()) :: map()
  def get_asset(wallet_id, account_id, asset_id) do
    get!("#{@base_path}/#{wallet_id}/accounts/#{account_id}/assets/#{asset_id}")
  end

  @doc """
  Add an asset to a specific account within a Non-Custodial Wallet.

  **operationId:** `AddEmbeddedWalletAsset`
  """
  @spec add_asset(String.t(), String.t(), String.t(), String.t()) :: map()
  def add_asset(wallet_id, account_id, asset_id, idempotency_key \\ "") do
    post!(
      "#{@base_path}/#{wallet_id}/accounts/#{account_id}/assets/#{asset_id}",
      "",
      idempotency_key
    )
  end

  @doc """
  Get the balance of a specific asset under a specific account within a
  Non-Custodial Wallet.

  **operationId:** `GetEmbeddedWalletAssetBalance`
  """
  @spec get_asset_balance(String.t(), String.t(), String.t()) :: map()
  def get_asset_balance(wallet_id, account_id, asset_id) do
    get!("#{@base_path}/#{wallet_id}/accounts/#{account_id}/assets/#{asset_id}/balance")
  end

  @doc """
  Refresh the balance of a specific asset under a specific account within a
  Non-Custodial Wallet.

  **operationId:** `RefreshEmbeddedWalletAssetBalance`
  """
  @spec refresh_asset_balance(String.t(), String.t(), String.t()) :: map()
  def refresh_asset_balance(wallet_id, account_id, asset_id) do
    put!(
      "#{@base_path}/#{wallet_id}/accounts/#{account_id}/assets/#{asset_id}/balance",
      ""
    )
  end

  # ─── Addresses ─────────────────────────────────────────────────────────────

  # get_addresses has a tighter pageSize ceiling (max 100) per the spec,
  # so it does not compose @pagination to avoid inheriting the default of 200.
  @get_addresses_schema [
    pageCursor: [type: :string, doc: "Cursor to the next page of results"],
    pageSize: [type: :integer, doc: "Number of items per page (min 1, max 100)"],
    sort: [
      type: {:in, [:address, :createdAt]},
      default: :createdAt,
      doc: "Field to sort by: `:address` or `:createdAt`"
    ],
    order: [
      type: {:in, [:asc, :desc]},
      default: :asc,
      doc: "Sort direction: `:asc` or `:desc`"
    ],
    enabled: [
      type: :boolean,
      doc: "When set, filters addresses by their enabled/disabled status"
    ]
  ]

  @doc """
  Get addresses for a specific asset under a specific account within a
  Non-Custodial Wallet.

  **operationId:** `GetEmbeddedWalletAddresses`

  ## Options

  #{NimbleOptions.docs(@get_addresses_schema)}
  """
  @spec get_addresses(String.t(), String.t(), String.t(), keyword()) :: map()
  def get_addresses(wallet_id, account_id, asset_id, opts \\ []) do
    {:ok, params} = NimbleOptions.validate(opts, @get_addresses_schema)

    query_string =
      params
      |> atom_to_string([:sort])
      |> atom_to_upper([:order])
      |> URI.encode_query()

    get!(
      "#{@base_path}/#{wallet_id}/accounts/#{account_id}/assets/#{asset_id}/addresses?#{query_string}"
    )
  end

  # ─── Devices ───────────────────────────────────────────────────────────────

  @list_devices_schema [
                         sort: [
                           type: {:in, [:createdAt]},
                           default: :createdAt,
                           doc: "Field to sort by"
                         ]
                       ] ++ @pagination

  @doc """
  Get a paginated list of registered devices for a specific Non-Custodial Wallet.

  **operationId:** `getEmbeddedWalletDevicesPaginated`

  ## Options

  #{NimbleOptions.docs(@list_devices_schema)}
  """
  @spec list_devices(String.t(), keyword()) :: map()
  def list_devices(wallet_id, opts \\ []) do
    {:ok, params} = NimbleOptions.validate(opts, @list_devices_schema)

    query_string =
      params
      |> atom_to_string([:sort])
      |> atom_to_upper([:order])
      |> URI.encode_query()

    get!("#{@base_path}/#{wallet_id}/devices_paginated?#{query_string}")
  end

  @doc """
  Get a specific device registered to a specific Non-Custodial Wallet.

  **operationId:** `GetEmbeddedWalletDevice`
  """
  @spec get_device(String.t(), String.t()) :: map()
  def get_device(wallet_id, device_id) do
    get!("#{@base_path}/#{wallet_id}/devices/#{device_id}")
  end

  @update_device_status_schema [
    enabled: [
      type: :boolean,
      required: true,
      doc: "Whether the device should be enabled (`true`) or disabled (`false`)"
    ]
  ]

  @doc """
  Update the enabled/disabled status of a specific device for a Non-Custodial Wallet.

  **operationId:** `updateEmbeddedWalletDeviceStatus`

  ## Options

  #{NimbleOptions.docs(@update_device_status_schema)}
  """
  @spec update_device_status(String.t(), String.t(), keyword(), String.t()) :: map()
  def update_device_status(wallet_id, device_id, params, idempotency_key \\ "") do
    {:ok, params} = NimbleOptions.validate(params, @update_device_status_schema)
    data = params |> Enum.into(%{}) |> Jason.encode!()
    patch!("#{@base_path}/#{wallet_id}/devices/#{device_id}/status", data, idempotency_key)
  end

  @doc """
  Get the key setup state of a specific device under a specific Non-Custodial Wallet.

  **operationId:** `GetEmbeddedWalletDeviceSetupState`
  """
  @spec get_device_setup_status(String.t(), String.t()) :: map()
  def get_device_setup_status(wallet_id, device_id) do
    get!("#{@base_path}/#{wallet_id}/devices/#{device_id}/setup_status")
  end

  # ─── Backup ────────────────────────────────────────────────────────────────

  @doc """
  Get wallet latest backup details, including the `deviceId` and backup time.

  **operationId:** `GetEmbeddedWalletLatestBackup`
  """
  @spec get_latest_backup(String.t()) :: map()
  def get_latest_backup(wallet_id) do
    get!("#{@base_path}/#{wallet_id}/backup/latest")
  end

  # ─── Public Key Info ───────────────────────────────────────────────────────

  @get_public_key_info_schema [
    derivationPath: [
      type: :string,
      required: true,
      doc:
        "Full BIP44 derivation path as a JSON-stringified integer array (first element must be 44)"
    ],
    algorithm: [
      type: {:in, [:MPC_ECDSA_SECP256K1, :MPC_ECDSA_SECP256R1, :MPC_EDDSA_ED25519]},
      required: true,
      doc:
        "Signing algorithm: `MPC_ECDSA_SECP256K1`, `MPC_ECDSA_SECP256R1`, or `MPC_EDDSA_ED25519`"
    ],
    compressed: [
      type: :boolean,
      doc: "When `true`, returns the public key in compressed format"
    ]
  ]

  @doc """
  Get the public key information based on derivation path and signing algorithm
  within a Non-Custodial Wallet.

  **operationId:** `getPublicKeyInfoNcw`

  ## Options

  #{NimbleOptions.docs(@get_public_key_info_schema)}
  """
  @spec get_public_key_info(String.t(), keyword()) :: map()
  def get_public_key_info(wallet_id, opts \\ []) do
    {:ok, params} = NimbleOptions.validate(opts, @get_public_key_info_schema)
    get!("#{@base_path}/#{wallet_id}/public_key_info?#{URI.encode_query(params)}")
  end

  @get_asset_public_key_info_schema [
    compressed: [
      type: :boolean,
      doc: "When `true`, returns the public key in compressed format"
    ]
  ]

  @doc """
  Get the public key of an asset associated with a specific account within a
  Non-Custodial Wallet, identified by its BIP44 change and address index.

  **operationId:** `GetEmbeddedWalletPublicKeyInfoForAddress`

  ## Options

  #{NimbleOptions.docs(@get_asset_public_key_info_schema)}
  """
  @spec get_asset_public_key_info(
          String.t(),
          String.t(),
          String.t(),
          non_neg_integer(),
          non_neg_integer(),
          keyword()
        ) :: map()
  def get_asset_public_key_info(
        wallet_id,
        account_id,
        asset_id,
        change,
        address_index,
        opts \\ []
      ) do
    {:ok, params} = NimbleOptions.validate(opts, @get_asset_public_key_info_schema)

    get!(
      "#{@base_path}/#{wallet_id}/accounts/#{account_id}/assets/#{asset_id}/#{change}/#{address_index}/public_key_info?#{URI.encode_query(params)}"
    )
  end

  @doc """
  Get the public key of an asset using the legacy internal path format.

  **operationId:** `getPublicKeyInfoForAddressNcw`

  > This endpoint is marked `x-internal` in the specification. Prefer
  > `get_asset_public_key_info/6` for all new integrations.

  ## Options

  #{NimbleOptions.docs(@get_asset_public_key_info_schema)}
  """
  @deprecated "Use get_asset_public_key_info/6 instead — this is a legacy internal endpoint"
  @spec get_asset_public_key_info_alt(
          String.t(),
          String.t(),
          String.t(),
          non_neg_integer(),
          non_neg_integer(),
          keyword()
        ) :: map()
  def get_asset_public_key_info_alt(
        wallet_id,
        account_id,
        asset_id,
        change,
        address_index,
        opts \\ []
      ) do
    {:ok, params} = NimbleOptions.validate(opts, @get_asset_public_key_info_schema)

    get!(
      "/v1/ncw/#{wallet_id}/accounts/#{account_id}/#{asset_id}/#{change}/#{address_index}/public_key_info?#{URI.encode_query(params)}"
    )
  end
end
