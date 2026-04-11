defmodule FireblocksSdk.Schema do
  @moduledoc """
  Shared NimbleOptions schemas used across multiple API modules.

  Only schemas that are genuinely reused by more than one module belong here.
  Module-specific schemas should be defined as `@<function>_schema` attributes
  directly in the module that uses them.
  """

  @doc """
  Schema for creating an external or internal wallet.
  Used by `FireblocksSdk.Api.ExternalWallet` and `FireblocksSdk.Api.InternalWallet`.
  """
  def wallet_create_request(),
    do: [
      name: [type: :string, required: true],
      customerRefId: [type: :string]
    ]

  @doc """
  Schema for setting the AML/KYT customer reference ID on an external or internal wallet.
  Used by `FireblocksSdk.Api.ExternalWallet` and `FireblocksSdk.Api.InternalWallet`.
  """
  def wallet_set_customer_ref_id_request(),
    do: [
      walletId: [type: :string, required: true],
      customerRefId: [type: :string, required: true]
    ]

  @doc """
  Schema for adding an asset to an external or internal wallet.
  Used by `FireblocksSdk.Api.ExternalWallet` and `FireblocksSdk.Api.InternalWallet`.
  """
  def wallet_add_asset_request(),
    do: [
      walletId: [type: :string, required: true],
      assetId: [type: :string, required: true],
      address: [type: :string],
      tag: [type: :string]
    ]
end
