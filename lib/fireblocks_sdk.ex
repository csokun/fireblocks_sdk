defmodule FireblocksSdk do
  alias FireblocksSdk.Schema
  alias FireblocksSdk.Request
  alias FireblocksSdk.Models

  @moduledoc """
  Documentation for `FireblocksSdk`.
  """

  @doc """
  Gets all assets that are currently supported by Fireblocks
  """
  @spec get_supported_assets() :: [Models.asset_type_response()]
  def get_supported_assets() do
    get("/v1/supported_assets")
  end

  @doc """
  Gets a list of vault accounts per page matching the given filter or path

  Supported options:\n#{NimbleOptions.docs(Schema.paged_vault_accounts_request_filters())}
  """
  @spec get_vault_accounts_with_page_info(map()) ::
          Models.paged_vault_accounts_response()
  def get_vault_accounts_with_page_info(options) do
    {:ok, params} = NimbleOptions.validate(options, Schema.paged_vault_accounts_request_filters())
    get("/v1/vault/accounts_paged?#{URI.encode_query(params)}")
  end

  @doc """
  Gets a single vault account
  """
  @spec get_vault_account_by_id(String.t()) :: Models.vault_account_response()
  def get_vault_account_by_id(vault_account_id) when is_binary(vault_account_id) do
    get("/v1/vault/accounts/#{vault_account_id}")
  end

  def get_vault_account_asset(vault_account_id, asset_id)
      when is_binary(vault_account_id) and
             is_binary(asset_id) do
    get("/v1/vault/accounts/#{vault_account_id}/#{asset_id}")
  end

  def get_deposit_addresses(vault_account_id, asset_id) do
    get("/v1/vault/accounts/#{vault_account_id}/#{asset_id}/addresses")
  end

  @doc """
  Get all vault assets balance overview

  Supported options:\n#{NimbleOptions.docs(Schema.vault_balance_filter())}
  """
  def get_vault_assets_balance(options) do
    {:ok, params} = NimbleOptions.validate(options, Schema.vault_balance_filter())
    get("/v1/vault/assets?#{URI.encode_query(params)}")
  end

  @doc """
  Creates a new transaction with the specified options

  Supported options:\n#{NimbleOptions.docs(Schema.transaction_request())}
  """
  def create_transaction(transaction, idempotent_key \\ "") do
    Request.post("/v1/transactions", transaction, idempotent_key)
  end

  defp get(path) do
    [_, data, _] = Request.get(path)
    data
  end
end
