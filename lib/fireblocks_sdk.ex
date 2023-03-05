defmodule FireblocksSdk do
  alias FireblocksSdk.Schema
  alias FireblocksSdk.Request

  @moduledoc """
  Documentation for `FireblocksSdk`.
  """

  @doc """
  Gets all assets that are currently supported by Fireblocks
  """
  @spec get_supported_assets() :: [FireblocksSdk.Types.asset_type_response()]
  def get_supported_assets() do
    Request.get("/v1/supported_assets")
  end

  @doc """
  Gets a list of vault accounts per page matching the given filter or path
  """
  @spec get_vault_accounts_with_page_info(Schema.paged_vault_accounts_request_filters()) ::
          FireblocksSdk.Types.paged_vault_accounts_response()
  def get_vault_accounts_with_page_info(options) do
    {:ok, params} = NimbleOptions.validate(options, Schema.paged_vault_accounts_request_filters())
    Request.get("/v1/vault/accounts_paged?#{URI.encode_query(params)}")
  end
end
