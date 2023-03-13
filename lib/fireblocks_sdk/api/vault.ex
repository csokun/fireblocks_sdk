defmodule FireblocksSdk.Api.Vault do
  alias FireblocksSdk.Schema
  import FireblocksSdk.Request
  alias FireblocksSdk.Models

  @doc """
  Creates a new vault account with the requested name.

  Options:\n#{NimbleOptions.docs(Schema.vault_create_request())}
  """
  def create(vault, idempotentKey \\ "") do
    {:ok, options} = NimbleOptions.validate(vault, Schema.vault_create_request())
    params = options |> Jason.encode!()
    post!("/v1/vault/accounts", params, idempotentKey)
  end

  @doc """
  Renames the requested vault account.
  """
  def rename(vault_id, name, idempotentKey \\ "") do
    params = %{name: name} |> Jason.encode!()
    put!("/v1/vault/accounts/#{vault_id}", params, idempotentKey)
  end

  @doc """
  Hides the requested vault account from the web console view.
  """
  def hide(vault_id, idempotentKey \\ "") when is_binary(vault_id) do
    post!("/v1/vault/accounts/#{vault_id}/hide", "", idempotentKey)
  end

  @doc """
  Makes a hidden vault account visible in web console view.
  """
  def unhide(vault_id, idempotentKey) when is_binary(vault_id) do
    post!("/v1/vault/accounts/#{vault_id}/unhide", "", idempotentKey)
  end

  @doc """
  Initiates activation for a wallet in a vault account.
  """
  def active(vault_id, asset_id, idempotentKey \\ "") do
    post!("/v1/vault/account/#{vault_id}/#{asset_id}/activate", "", idempotentKey)
  end

  @doc """
  Assigns an AML/KYT customer reference ID for the vault account.

  Options:\n#{NimbleOptions.docs(Schema.vault_set_customer_ref_id_request())}
  """
  def set_customer_ref_id(reference, idempotentKey \\ "") do
    {:ok, options} = NimbleOptions.validate(reference, Schema.vault_set_customer_ref_id_request())
    vault_id = options[:vaultId]
    params = options |> Keyword.delete(:vaultId) |> Jason.encode!()
    post!("/v1/vault/accounts/#{vault_id}/set_customer_ref_id", params, idempotentKey)
  end

  @doc """
  Sets the autofueling property of the vault account to enabled or disabled.

  Options:\n#{NimbleOptions.docs(Schema.vault_auto_fuel_request())}
  """
  def set_auto_fuel(fuel, idempotentKey \\ "") do
    {:ok, options} = NimbleOptions.validate(fuel, Schema.vault_auto_fuel_request())
    vault_id = options[:vaultId]
    params = options |> Keyword.delete(:vaultId) |> Jason.encode!()
    post!("/v1/vault/accounts/#{vault_id}/set_auto_fuel", params, idempotentKey)
  end

  @doc """
  Gets all vault accounts in your workspace.

  Options:\n#{NimbleOptions.docs(Schema.vault_account_filter())}
  """
  def get_vault_accounts(filter) do
    {:ok, options} = NimbleOptions.validate(filter, Schema.vault_account_filter())
    query_string = options |> URI.encode_query(options)
    get!("/v1/vault/accounts?#{query_string}")
  end

  @doc """
  Gets a list of vault accounts per page matching the given filter or path

  Supported options:\n#{NimbleOptions.docs(Schema.paged_vault_accounts_request_filters())}
  """
  @spec get_vault_accounts_with_page_info(map()) ::
          Models.paged_vault_accounts_response()
  def get_vault_accounts_with_page_info(options) do
    {:ok, params} = NimbleOptions.validate(options, Schema.paged_vault_accounts_request_filters())
    get!("/v1/vault/accounts_paged?#{URI.encode_query(params)}")
  end

  @doc """
  Gets a single vault account
  """
  @spec get_vault_account_by_id(String.t()) :: Models.vault_account_response()
  def get_vault_account_by_id(vault_id) when is_binary(vault_id) do
    get!("/v1/vault/accounts/#{vault_id}")
  end

  @doc """
  Returns a wallet for a specific asset of a vault account.
  """
  def get_vault_account_asset(vault_id, asset_id)
      when is_binary(vault_id) and
             is_binary(asset_id) do
    get!("/v1/vault/accounts/#{vault_id}/#{asset_id}")
  end

  @doc """
  Lists all addresses for specific asset of vault account.
  """
  def get_deposit_addresses(vault_id, asset_id) do
    get!("/v1/vault/accounts/#{vault_id}/#{asset_id}/addresses")
  end

  @doc """
  Gets the assets amount summary for all accounts or filtered accounts.

  Supported options:\n#{NimbleOptions.docs(Schema.vault_balance_filter())}
  """
  def get_vault_assets_balance(options) do
    {:ok, params} = NimbleOptions.validate(options, Schema.vault_balance_filter())
    get!("/v1/vault/assets?#{URI.encode_query(params)}")
  end
end
