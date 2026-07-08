defmodule FireblocksSdk.Api.Vault do
  import FireblocksSdk.Request

  @base_path "/v1/vault"
  @accounts_path "/v1/vault/accounts"

  # Shared pagination fields used by multiple schemas in this module
  @pagination [
    limit: [
      type: :non_neg_integer,
      default: 200,
      doc:
        "The maximum number of results in a single response. The default is 200 and the maximum is 1000."
    ],
    before: [
      type: :string,
      doc:
        "Fetches the next paginated response before this element. This element is a cursor and is returned at the response of the previous page."
    ],
    after: [
      type: :string,
      doc:
        "Fetches the next paginated response after this element. This element is a cursor and is returned at the response of the previous page."
    ]
  ]

  @create_schema [
    name: [type: :string, required: true],
    hiddenOnUI: [type: :boolean, default: false],
    customerRefId: [type: :string],
    autoFuel: [type: :boolean, default: true],
    autoAssign: [
      type: :boolean,
      default: false,
      doc: """
      Applicable only when the vault account type is **KEY_LINK**. For MPC, this parameter will be ignored.
      If set to true and there are available keys, random keys will be assigned to the newly created vault account.
      If set to true and there are no available keys to be assigned, it will return an error. If set to false, the vault account will be created without any keys.
      """
    ]
  ]

  @doc """
  Creates a new vault account with the requested name.
  ```
  FireblocksSdk.Api.Vault.create([
    name: "MyVault",
    hiddenOnUI: false,
    customerRefId: "MyCustomerRefId",
    autoFuel: false
  ])
  ```

  Options:\n#{NimbleOptions.docs(@create_schema)}
  """
  def create(vault, idempotentKey \\ "") do
    {:ok, options} = NimbleOptions.validate(vault, @create_schema)
    params = options |> Enum.into(%{}) |> Jason.encode!()
    post!(@accounts_path, params, idempotentKey)
  end

  @doc """
  Renames the requested vault account.
  """
  def rename(vault_id, name, idempotentKey \\ "") do
    params = %{name: name} |> Jason.encode!()
    put!("#{@accounts_path}/#{vault_id}", params, idempotentKey)
  end

  @doc """
  Hides the requested vault account from the web console view.
  """
  def hide(vault_id, idempotentKey \\ "") when is_binary(vault_id) do
    post!("#{@accounts_path}/#{vault_id}/hide", "", idempotentKey)
  end

  @doc """
  Makes a hidden vault account visible in web console view.
  """
  def unhide(vault_id, idempotentKey \\ "") when is_binary(vault_id) do
    post!("#{@accounts_path}/#{vault_id}/unhide", "", idempotentKey)
  end

  @activate_schema [
    vaultAccountId: [
      type: :string,
      required: true,
      doc: "The ID of the vault account to return, or 'default' for the default vault account"
    ],
    assetId: [type: :string, required: true, doc: "The ID of the asset"],
    blockchainWalletType: [
      type: :string,
      doc: "Optional immutable blockchain wallet type to store per tenant+vault"
    ]
  ]

  @doc """
  Initiates activation for a wallet in a vault account. Activation is required for tokens that need an on-chain transaction for creation (XLM tokens, SOL tokens etc).
  **Endpoint Permission**: Admin, Non-Signing Admin, Signer, Approver, Editor.

  ```
    FireblocksSdk.Api.Vault.activate([
      vaultAccountId: "1",
      assetId: "XLM"
    ])
  ```

  Options:\n#{NimbleOptions.docs(@activate_schema)}
  """
  def activate(opts, idempotentKey \\ "") do
    {:ok, options} = NimbleOptions.validate(opts, @activate_schema)
    vault_id = options[:vaultAccountId]
    asset_id = options[:vaultAccountId]

    params =
      options
      |> Keyword.delete(:vaultAccountId)
      |> Keyword.delete(:assetId)
      |> Enum.into(%{})
      |> Jason.encode!()

    post!("#{@accounts_path}/#{vault_id}/#{asset_id}/activate", params, idempotentKey)
  end

  @set_customer_ref_id_schema [
    vaultId: [type: :string, required: true],
    assetId: [type: :string],
    addressId: [type: :string],
    customerRefId: [type: :string, required: true]
  ]

  @doc """
  Assigns an AML/KYT customer reference ID for the vault account.

  ```
  # set customer reference on vault
  FireblocksSdk.Api.Vault.set_customer_ref_id([
    vaultId: "1",
    customerRefId: "Customer#1"
  ])

  # set customer reference on vault asset
  FireblocksSdk.Api.Vault.set_customer_ref_id([
    vaultId: "1",
    assetId: "ETH",
    customerRefId: "Customer#1"
  ])
  ```

  Options:\n#{NimbleOptions.docs(@set_customer_ref_id_schema)}
  """
  def set_customer_ref_id(reference, idempotentKey \\ "") do
    {:ok, options} = NimbleOptions.validate(reference, @set_customer_ref_id_schema)
    vault_id = options[:vaultId]
    asset_id = options[:assetId]
    address_id = options[:addressId]
    path = "#{@accounts_path}/#{vault_id}"

    path =
      case asset_id != nil and address_id != nil do
        true -> "#{path}/#{asset_id}/addresses/#{address_id}/set_customer_ref_id"
        _ -> "#{path}/set_customer_ref_id"
      end

    params = %{customerRefId: options[:customerRefId]} |> Jason.encode!()
    post!(path, params, idempotentKey)
  end

  @set_auto_fuel_schema [
    vaultId: [type: :string, required: true],
    autoFuel: [type: :boolean, required: true, default: true]
  ]

  @doc """
  Sets the autofueling property of the vault account to enabled or disabled.

  Options:\n#{NimbleOptions.docs(@set_auto_fuel_schema)}
  """
  def set_auto_fuel(fuel, idempotentKey \\ "") do
    {:ok, options} = NimbleOptions.validate(fuel, @set_auto_fuel_schema)
    vault_id = options[:vaultId]
    params = options |> Keyword.delete(:vaultId) |> Enum.into(%{}) |> Jason.encode!()
    post!("#{@accounts_path}/#{vault_id}/set_auto_fuel", params, idempotentKey)
  end

  @create_wallet_schema [
    vaultId: [type: :string, required: true],
    assetId: [type: :string, required: true],
    eosAccountName: [type: :string]
  ]

  @doc """
  Creates a wallet for a specific asset in a vault account.

  ```
  FireblocksSdk.Api.Vault.create_wallet([
    vaultId: "1",
    assetId: "XLM"
  ])
  ```

  Options:\n#{NimbleOptions.docs(@create_wallet_schema)}
  """
  def create_wallet(wallet, idempotentKey \\ "") do
    {:ok, options} = NimbleOptions.validate(wallet, @create_wallet_schema)
    vault_id = options[:vaultId]
    asset_id = options[:assetId]

    post!("#{@accounts_path}/#{vault_id}/#{asset_id}", "", idempotentKey)
  end

  @doc """
  Updates the balance of a specific asset in a vault account.
  """
  def refresh_balance(vault_id, asset_id, idempotentKey \\ "") do
    post!("#{@accounts_path}/#{vault_id}/#{asset_id}/balance", "", idempotentKey)
  end

  @doc """
  Converts an existing segwit address to the legacy format.
  """
  def segwit_to_legacy(vault_id, asset_id, address_id, idempotentKey \\ "") do
    post!(
      "#{@accounts_path}/#{vault_id}/#{asset_id}/addresses/#{address_id}/create_legacy",
      "",
      idempotentKey
    )
  end

  @doc """
  Get the maximum amount of a particular asset that can be spent in a single transaction from a specified vault account
  (UTXO assets only, with a limitation on number of inputs embedded).

  Send several transactions if you want to spend more than the maximum spendable amount.
  """
  def get_utxo_max_spendable_amount(vault_id, asset_id, manual_signing \\ false) do
    get!(
      "#{@accounts_path}/#{vault_id}/#{asset_id}/max_spendable_amount?manualSigning=#{manual_signing}"
    )
  end

  @doc """
  Get UTXO unspent input information.
  """
  def get_utxo_unspent_inputs(vault_id, asset_id) do
    get!("#{@accounts_path}/#{vault_id}/#{asset_id}/unspent_inputs")
  end

  @get_public_key_info_schema [
    vaultId: [type: :string],
    assetId: [type: :string],
    addressId: [type: :string],
    change: [type: :string],
    derivationPath: [type: :string, required: true],
    algorithm: [type: :string, required: true],
    compressed: [type: :boolean]
  ]

  @doc """
  Gets the public key information based on derivation path and signing algorithm.

  Options:\n#{NimbleOptions.docs(@get_public_key_info_schema)}
  """
  def get_public_key_info(filter) do
    {:ok, options} = NimbleOptions.validate(filter, @get_public_key_info_schema)
    vault_id = options[:vaultId]
    asset_id = options[:assetId]
    address_id = options[:addressId]
    change = options[:change]

    path =
      case vault_id != nil and asset_id != nil and address_id != nil and change != nil do
        true ->
          "#{@accounts_path}/#{vault_id}/#{asset_id}/#{change}/#{address_id}/public_key_info"

        _ ->
          "#{@base_path}/public_key_info"
      end

    query_string =
      %{
        derivationPath: options[:derivationPath],
        algorithm: options[:algorithm],
        compressed: options[:compressed] || false
      }
      |> URI.encode_query()

    get!("#{path}?#{query_string}")
  end

  @update_address_description_schema [
    vaultId: [type: :string, required: true],
    assetId: [type: :string, required: true],
    addressId: [type: :string, required: true],
    description: [type: :string, default: ""]
  ]

  @doc """
  Updates the description of an existing address of an asset in a vault account.

  Options:\n#{NimbleOptions.docs(@update_address_description_schema)}
  """
  def update_address_description(change, idempotentKey \\ "") do
    {:ok, options} = NimbleOptions.validate(change, @update_address_description_schema)

    vault_id = options[:vaultId]
    asset_id = options[:assetId]
    address_id = options[:addressId]

    params =
      options
      |> Keyword.delete(:vaultId)
      |> Keyword.delete(:assetId)
      |> Keyword.delete(:addressId)
      |> Enum.into(%{})
      |> Jason.encode!()

    put!(
      "#{@accounts_path}/#{vault_id}/#{asset_id}/addresses/#{address_id}",
      params,
      idempotentKey
    )
  end

  @list_schema [
                 namePrefix: [type: :string],
                 nameSuffix: [type: :string],
                 minAmountThreshold: [type: :non_neg_integer],
                 includeTagIds: [
                   type: {:list, :string},
                   default: [],
                   doc: "list of tag IDs to include"
                 ],
                 excludeTagIds: [
                   type: {:list, :string},
                   default: [],
                   doc: "list of tag IDs to exclude"
                 ],
                 assetId: [type: :string],
                 orderBy: [type: {:in, [:asc, :desc]}, doc: "order by `:asc` or `:desc`"]
               ] ++ @pagination

  @doc """
  Gets a list of vault accounts per page matching the given filter or path

  ```
  FireblocksSdk.Api.Vault.list([
    namePrefix: "Operations",
    assetId: "ETH",
    limit: 30
  ])
  ```

  Supported options:\n#{NimbleOptions.docs(@list_schema)}
  """
  def list(listing) do
    {:ok, params} = NimbleOptions.validate(listing, @list_schema)

    query_string =
      params
      |> list_to_string([:includeTagIds, :excludeTagIds])
      |> atom_to_upper([:orderBy])
      |> URI.encode_query()

    get!("#{@base_path}/accounts_paged?#{query_string}")
  end

  @doc """
  Gets a single vault account

  - `vault_id`: Fireblock vault id
  """
  def get(vault_id) when is_binary(vault_id) do
    get!("#{@accounts_path}/#{vault_id}")
  end

  @doc """
  Get the asset balance for a vault account.

  ```
  FireblocksSdk.Api.Vault.get_asset_balance("1", "XLM")
  ```
  """
  def get_asset_balance(vault_id, asset_id)
      when is_binary(vault_id) and
             is_binary(asset_id) do
    get!("#{@accounts_path}/#{vault_id}/#{asset_id}")
  end

  @doc """
  Creates a new deposit address for an asset of a vault account.
  """
  def create_new_asset_deposit_address(vault_id, asset_id, idempotentKey \\ "") do
    post!("#{@accounts_path}/#{vault_id}/#{asset_id}/addresses", "", idempotentKey)
  end

  @list_vault_asset_addresses_schema [
                                       vaultAccountId: [type: :string, required: true],
                                       assetId: [type: :string, required: true]
                                     ] ++ @pagination

  @doc """
  Returns a paginated response of the addresses for a given vault account and asset.

  ```
  FireblocksSdk.Api.list_vault_asset_addresses([
    vaultAccountId: "1",
    assetId: "XLM",
    limit: 200
  ])
  ```

  Options:\n#{NimbleOptions.docs(@list_vault_asset_addresses_schema)}
  """
  def list_vault_asset_addresses(options) do
    {:ok, params} = NimbleOptions.validate(options, @list_vault_asset_addresses_schema)
    vaultId = params[:vaultAccountId]
    assetId = params[:assetId]

    query_string =
      params
      |> Keyword.delete(:vaultAccountId)
      |> Keyword.delete(:assetId)
      |> URI.encode_query()

    get!("#{@accounts_path}/#{vaultId}/#{assetId}/addresses_paginated?#{query_string}")
  end

  @get_assets_balance_schema [
    accountNamePrefix: [type: :string],
    accountNameSuffix: [type: :string]
  ]

  @doc """
  Gets the assets amount summary for all accounts or filtered accounts.

  ```
  FireblocksSdk.Api.Vault.get_assets_balance([
    accountNamePrefix: "Operation"
  ])
  ```

  Supported options:\n#{NimbleOptions.docs(@get_assets_balance_schema)}
  """
  def get_assets_balance(options) do
    {:ok, params} = NimbleOptions.validate(options, @get_assets_balance_schema)
    get!("#{@base_path}/assets?#{URI.encode_query(params)}")
  end

  @get_asset_wallets_schema [
                              totalAmountLargerThan: [
                                type: {:or, [:non_neg_integer, :float]},
                                doc:
                                  "When specified, only asset wallets with total balance larger than this amount are returned."
                              ],
                              assetId: [
                                type: :string,
                                doc:
                                  "When specified, only asset wallets cross vault accounts that have this asset ID are returned."
                              ],
                              orderBy: [
                                type: {:in, [:asc, :desc]},
                                doc: "order by `:asc` or `:desc`"
                              ]
                            ] ++ @pagination

  @doc """
  Gets all asset wallets at all of the vault accounts in your workspace. An asset wallet is an asset at a vault account. This method allows fast traversal of all account balances.

  ```
  FireblocksSdk.Api.Vault.get_asset_wallets([
    totalAmountLargerThan: 0,
    assetId: "USDC",
    limit: 1
  ])
  ```

  Supported options:\n#{NimbleOptions.docs(@get_asset_wallets_schema)}
  """
  def get_asset_wallets(options) do
    {:ok, params} = NimbleOptions.validate(options, @get_asset_wallets_schema)
    get!("#{@base_path}/asset_wallets?#{URI.encode_query(params)}")
  end

  @create_multiple_accounts_schema [
    count: [type: :integer, required: true, doc: "Number of vault accounts to create"],
    baseAssetIds: [
      type: {:list, :string},
      required: true,
      doc: "Array of base asset IDs to initialise in each new vault account"
    ],
    names: [
      type: {:list, :string},
      doc:
        "Names to assign to vault accounts. Cannot be combined with `vaultAccountNamesStartingIndex` or `prefix`"
    ],
    vaultAccountNamesStartingIndex: [
      type: :integer,
      doc: "Copy vault account names starting from this index. Cannot be combined with `names`"
    ],
    prefix: [
      type: :string,
      doc:
        "When copying from existing vault accounts (`vaultAccountNamesStartingIndex`), adds a prefix to the names. Cannot be combined with `names`"
    ],
    tagIds: [
      type: {:list, :string},
      doc: "Optional list of tag IDs (UUIDs, max 20) to attach to all created vault accounts"
    ]
  ]

  @doc """
  Bulk creation of new vault accounts.

  Initiates a background job that creates multiple vault accounts in a single request.
  Poll the returned `jobId` with `get_create_multiple_accounts_job/1` to track progress.

  ```
  FireblocksSdk.Api.Vault.create_multiple_accounts([
    count: 10,
    baseAssetIds: ["ETH", "BTC"],
    prefix: "Ops-"
  ])
  ```

  Options:\n#{NimbleOptions.docs(@create_multiple_accounts_schema)}
  """
  def create_multiple_accounts(params, idempotent_key \\ "") do
    {:ok, options} = NimbleOptions.validate(params, @create_multiple_accounts_schema)
    data = options |> Enum.into(%{}) |> Jason.encode!()
    post!("#{@accounts_path}/bulk", data, idempotent_key)
  end

  @doc """
  Get the status of a bulk vault account creation job.

  - `job_id`: The job ID returned by `create_multiple_accounts/2`
  """
  def get_create_multiple_accounts_job(job_id) when is_binary(job_id) do
    get!("#{@accounts_path}/bulk/#{job_id}")
  end

  @create_multiple_deposit_addresses_schema [
    vaultAccountId: [
      type: :integer,
      required: true,
      doc: "Existing vault account ID to add deposit addresses to"
    ],
    assetId: [type: :string, required: true, doc: "Asset ID"],
    count: [type: :integer, required: true, doc: "Number of deposit addresses to create"],
    descriptions: [
      type: {:list, :string},
      doc: "Descriptions for the newly created addresses"
    ],
    vaultAccountToCopyDescFrom: [
      type: :integer,
      doc:
        "Existing vault account ID to copy deposit address descriptions from when no `descriptions` are provided"
    ],
    vaultAccountToCopyDescFromIndex: [
      type: :integer,
      doc:
        "Starting index within the source vault account to copy deposit address descriptions from"
    ]
  ]

  @doc """
  Bulk creation of deposit addresses for a vault account asset.

  Initiates a background job that creates multiple deposit addresses in a single request.
  Poll the returned `jobId` with `get_create_multiple_deposit_addresses_job/1` to track progress.

  ```
  FireblocksSdk.Api.Vault.create_multiple_deposit_addresses([
    vaultAccountId: 1,
    assetId: "ETH",
    count: 5
  ])
  ```

  Options:\n#{NimbleOptions.docs(@create_multiple_deposit_addresses_schema)}
  """
  def create_multiple_deposit_addresses(params, idempotent_key \\ "") do
    {:ok, options} =
      NimbleOptions.validate(params, @create_multiple_deposit_addresses_schema)

    data = options |> Enum.into(%{}) |> Jason.encode!()
    post!("#{@accounts_path}/addresses/bulk", data, idempotent_key)
  end

  @doc """
  Get the status of a bulk deposit address creation job.

  - `job_id`: The job ID returned by `create_multiple_deposit_addresses/2`
  """
  def get_create_multiple_deposit_addresses_job(job_id) when is_binary(job_id) do
    get!("#{@accounts_path}/addresses/bulk/#{job_id}")
  end

  @attach_detach_tags_schema [
    vaultAccountIds: [
      type: {:list, :string},
      required: true,
      doc: "The IDs of the vault accounts to modify tags on (1–100 accounts)"
    ],
    tagIdsToAttach: [
      type: {:list, :string},
      doc: "The IDs of the tags to attach (1–20 UUIDs)"
    ],
    tagIdsToDetach: [
      type: {:list, :string},
      doc: "The IDs of the tags to detach (1–20 UUIDs)"
    ]
  ]

  @doc """
  Attach or detach tags from one or more vault accounts.

  ```
  FireblocksSdk.Api.Vault.attach_detach_tags([
    vaultAccountIds: ["1", "2", "3"],
    tagIdsToAttach: ["tag-uuid-1"],
    tagIdsToDetach: ["tag-uuid-2"]
  ])
  ```

  Options:\n#{NimbleOptions.docs(@attach_detach_tags_schema)}
  """
  def attach_detach_tags(params, idempotent_key \\ "") do
    {:ok, options} = NimbleOptions.validate(params, @attach_detach_tags_schema)
    data = options |> Enum.into(%{}) |> Jason.encode!()
    post!("#{@accounts_path}/attached_tags", data, idempotent_key)
  end

  @doc """
  Get the maximum BIP44 index used for a vault account asset.

  Returns the highest derivation index currently in use for the given vault account
  and asset, which is useful before generating new addresses.

  - `vault_account_id`: The vault account ID
  - `asset_id`: The asset ID (e.g. `"ETH"`)
  """
  def get_max_bip44_index_used(vault_account_id, asset_id)
      when is_binary(vault_account_id) and is_binary(asset_id) do
    get!("#{@accounts_path}/#{vault_account_id}/#{asset_id}/max_bip44_index_used")
  end

  @doc """
  Get the aggregated vault balance for a specific asset across all vault accounts.

  - `asset_id`: The asset ID (e.g. `"ETH"`)
  """
  def get_vault_balance_by_asset(asset_id) when is_binary(asset_id) do
    get!("#{@base_path}/assets/#{asset_id}")
  end

  @doc """
  Look up a vault account by blockchain address
  """
  def lookup_by_address(address),
    do: get!("#{@base_path}/lookup_by_address?address=#{address}")

  @doc """
  Get the USDC gateway address

  Returns the USDC Gateway wallet information associated with the given vault account.

  **Note**: This endpoint is currently in beta and might be subject to changes.
  """
  def get_usdc_gateway(vault_id),
    do: get!("#{@accounts_path}/#{vault_id}/usdc_gateway")

  @doc """
  Activates the USDC Gateway wallet associated with the given vault account. If the wallet does not yet exist it is created in an activated state.

  **Note**: This endpoint is currently in beta and might be subject to changes.
  **Endpoint Permission**: Admin, Non-Signing Admin, Signer, Approver.
  """
  def activate_usdc_gateway(vault_id, idempotentKey \\ ""),
    do: post!("#{@accounts_path}/#{vault_id}/usdc_gateway/activate", "", idempotentKey)

  @doc """
  Deactivates the USDC Gateway wallet associated with the given vault account.

  **Note**: This endpoint is currently in beta and might be subject to changes.
  **Endpoint Permission**: Admin, Non-Signing Admin, Signer, Approver.
  """
  def deactivate_usdc_gateway(vault_id, idempotentKey \\ ""),
    do: post!("#{@accounts_path}/#{vault_id}/usdc_gateway/deactivate", "", idempotentKey)
end
