defmodule FireblocksSdk.Api.ExchangeAccount do
  alias FireblocksSdk.Schema
  import FireblocksSdk.Request

  @base_path "/v1/exchange_accounts"

  @doc """
  List all exchange accounts.

  Options: \n#{NimbleOptions.docs(Schema.exchange_accounts_request())}
  """
  def get_accounts(filter) do
    {:ok, params} = NimbleOptions.validate(filter, Schema.exchange_accounts_request())

    query_string =
      params
      |> URI.encode_query()

    get!("#{@base_path}/paged?#{query_string}")
  end

  @doc """
  Find a specific exchange account.
  """
  def get_account(exchangeId) when is_binary(exchangeId) do
    get!("#{@base_path}/#{exchangeId}")
  end

  @doc """
  Find an asset for an exchange account.
  """
  def get_exchange_asset(exchangeId, assetId) when is_binary(exchangeId) and is_binary(assetId) do
    get!("#{@base_path}/#{exchangeId}/#{assetId}")
  end

  @doc """
  Transfer funds between trading accounts under the same exchange account.

  Options:\n#{NimbleOptions.docs(Schema.exchange_transfer_request())}
  """
  def internal_transfer(trade, idempotentKey \\ "") do
    {:ok, options} = NimbleOptions.validate(trade, Schema.exchange_transfer_request())
    exchangeId = options[:exchangeId]
    data = options |> Keyword.delete(:exchangeId) |> Jason.encode!()
    post!("#{@base_path}/#{exchangeId}/internal_transfer", data, idempotentKey)
  end

  @doc """
  Convert exchange account funds from the source asset to the destination asset. Coinbase (USD to USDC, USDC to USD) and Bitso (MXN to USD) are supported conversions.

  Options:\n#{NimbleOptions.docs(Schema.exchange_convert_request())}
  """
  def convert(request, idempotentKey \\ "") do
    {:ok, options} = NimbleOptions.validate(request, Schema.exchange_convert_request())
    exchangeId = options[:exchangeId]
    data = options |> Keyword.delete(:exchangeId) |> Jason.encode!()
    post!("#{@base_path}/#{exchangeId}/convert", data, idempotentKey)
  end

  @doc """
  Find an asset in an exchange account
  """
  def get_asset(exchange_id, asset_id) when is_binary(exchange_id) when is_binary(asset_id) do
    get!("#{@base_path}/#{exchange_id}/#{asset_id}")
  end

  @doc """
  Get public key to encrypt exchange credentials
  """
  def get_credentials_public_key() do
    get!("#{@base_path}/credentials_public_key")
  end
end
