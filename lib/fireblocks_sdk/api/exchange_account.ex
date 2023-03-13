defmodule FireblocksSdk.Api.ExchangeAccount do
  alias FireblocksSdk.Schema
  import FireblocksSdk.Request

  @base_path "/v1/exchange_accounts"

  @doc """
  List all exchange accounts.
  """
  def get_accounts() do
    get!(@base_path)
  end

  @doc """
  Find a specific exchange account.
  """
  def get_account(exchangeId) do
    get!("#{@base_path}/#{exchangeId}")
  end

  @doc """
  Find an asset for an exchange account.
  """
  def get_exchange_asset(exchangeId, assetId) do
    get!("#{@base_path}/#{exchangeId}/#{assetId}")
  end

  @doc """
  Transfer funds between trading accounts under the same exchange account.

  Options:\n#{NimbleOptions.docs(Schema.exchange_transfer_request())}
  """
  def transfer(trade, idempotentKey \\ "") do
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
end
