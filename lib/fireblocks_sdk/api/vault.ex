defmodule FireblocksSdk.Api.Vault do
  alias FireblocksSdk.Schema
  import FireblocksSdk.Request

  @base_path "/v1/vault"
  @accounts_path "/v1/vault/accounts"

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

  Options:\n#{NimbleOptions.docs(Schema.vault_create_request())}
  """
  def create(vault, idempotentKey \\ "") do
    {:ok, options} = NimbleOptions.validate(vault, Schema.vault_create_request())
    params = options |> Jason.encode!()
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

  @doc """
  Initiates activation for a wallet in a vault account.
  """
  def active(vault_id, asset_id, idempotentKey \\ "") do
    post!("#{@accounts_path}/#{vault_id}/#{asset_id}/activate", "", idempotentKey)
  end

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

  Options:\n#{NimbleOptions.docs(Schema.vault_set_customer_ref_id_request())}
  """
  def set_customer_ref_id(reference, idempotentKey \\ "") do
    {:ok, options} = NimbleOptions.validate(reference, Schema.vault_set_customer_ref_id_request())
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

  @doc """
  Sets the autofueling property of the vault account to enabled or disabled.

  Options:\n#{NimbleOptions.docs(Schema.vault_auto_fuel_request())}
  """
  def set_auto_fuel(fuel, idempotentKey \\ "") do
    {:ok, options} = NimbleOptions.validate(fuel, Schema.vault_auto_fuel_request())
    vault_id = options[:vaultId]
    params = options |> Keyword.delete(:vaultId) |> Jason.encode!()
    post!("#{@accounts_path}/#{vault_id}/set_auto_fuel", params, idempotentKey)
  end

  @doc """
  Creates a wallet for a specific asset in a vault account.

  ```
  FireblocksSdk.Api.Vault.create_wallet([
    vaultId: "1",
    assetId: "XLM"
  ])
  ```

  Options:\n#{NimbleOptions.docs(Schema.vault_create_wallet_request())}
  """
  def create_wallet(wallet, idempotentKey \\ "") do
    {:ok, options} = NimbleOptions.validate(wallet, Schema.vault_create_wallet_request())
    vault_id = options[:vaultId]
    asset_id = options[:assetId]

    params =
      options
      |> Keyword.delete(:vaultId)
      |> Keyword.delete(:assetId)
      |> Jason.encode!()

    post!("#{@accounts_path}/#{vault_id}/#{asset_id}", params, idempotentKey)
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
      "#{@base_path}/#{vault_id}/#{asset_id}/addresses/#{address_id}/create_legacy",
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
      "#{@base_path}/#{vault_id}/#{asset_id}/max_spendable_amount?manualSignging=#{manual_signing}"
    )
  end

  @doc """
  Get UTXO unspent input information.
  """
  def get_utxo_unspent_inputs(vault_id, asset_id) do
    get!("#{@base_path}/#{vault_id}/#{asset_id}/unspent_inputs")
  end

  @doc """
  Gets the public key information based on derivation path and signing algorithm.

  Options:\n#{NimbleOptions.docs(Schema.vault_public_key_info_filter())}
  """
  def get_public_key_info(filter) do
    {:ok, options} = NimbleOptions.validate(filter, Schema.vault_public_key_info_filter())
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

  @doc """
  Updates the description of an existing address of an asset in a vault account.

  Options:\n#{NimbleOptions.docs(Schema.vault_address_description_request())}
  """
  def update_address_description(change, idempotentKey \\ "") do
    {:ok, options} = NimbleOptions.validate(change, Schema.vault_address_description_request())

    vault_id = options[:vaultId]
    asset_id = options[:assetId]
    address_id = options[:addressId]

    params =
      options
      |> Keyword.delete(:vaultId)
      |> Keyword.delete(:assetId)
      |> Keyword.delete(:addressId)
      |> Jason.encode!()

    post!(
      "#{@accounts_path}/#{vault_id}/#{asset_id}/addresses/#{address_id}",
      params,
      idempotentKey
    )
  end

  @doc """
  Gets a list of vault accounts per page matching the given filter or path

  ```
  FireblocksSdk.Api.Vault.get_vault_accounts_with_page_info([
    namePrefix: "Operations",
    assetId: "ETH",
    limit: 30
  ])
  ```

  Supported options:\n#{NimbleOptions.docs(Schema.paged_vault_accounts_request_filters())}
  """
  def get_vault_accounts_with_page_info(options) do
    {:ok, params} = NimbleOptions.validate(options, Schema.paged_vault_accounts_request_filters())
    get!("#{@base_path}/accounts_paged?#{URI.encode_query(params)}")
  end

  @doc """
  Gets a single vault account

  - `vault_id`: Fireblock vault id
  """
  def get_vault_account_by_id(vault_id) when is_binary(vault_id) do
    get!("#{@accounts_path}/#{vault_id}")
  end

  @doc """
  Get the asset balance for a vault account.

  ```
  FireblocksSdk.Api.Vault.get_vault_account_asset("1", "XLM")
  ```
  """
  def get_vault_account_asset(vault_id, asset_id)
      when is_binary(vault_id) and
             is_binary(asset_id) do
    get!("#{@accounts_path}/#{vault_id}/#{asset_id}")
  end

  @doc """
  Lists all addresses for specific asset of vault account.
  """
  def get_deposit_addresses(vault_id, asset_id) do
    get!("#{@accounts_path}/#{vault_id}/#{asset_id}/addresses")
  end

  @doc """
  Gets the assets amount summary for all accounts or filtered accounts.

  Supported options:\n#{NimbleOptions.docs(Schema.vault_balance_filter())}
  """
  def get_vault_assets_balance(options) do
    {:ok, params} = NimbleOptions.validate(options, Schema.vault_balance_filter())
    get!("#{@base_path}/assets?#{URI.encode_query(params)}")
  end
end
