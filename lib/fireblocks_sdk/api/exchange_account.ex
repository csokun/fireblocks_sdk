defmodule FireblocksSdk.Api.ExchangeAccount do
  import FireblocksSdk.Request

  @base_path "/v1/exchange_accounts"

  @trading_account_type [
    :coin_futures,
    :coin_margined_swap,
    :exchange,
    :funding,
    :fundable,
    :futures,
    :futures_cross,
    :margin,
    :margin_cross,
    :options,
    :spot,
    :usdt_margined_swap_cross,
    :usdt_futures,
    :unified
  ]

  @get_accounts_schema [
    before: [type: :string, doc: "Fetch results before this cursor"],
    after: [type: :string, doc: "Fetch results after this cursor"],
    limit: [type: :non_neg_integer, default: 3, doc: "Maximum number of results to return"]
  ]

  @doc """
  List all exchange accounts (paginated).

  Options:\n#{NimbleOptions.docs(@get_accounts_schema)}
  """
  def get_accounts(filter \\ []) do
    {:ok, params} = NimbleOptions.validate(filter, @get_accounts_schema)
    query_string = params |> URI.encode_query()
    get!("#{@base_path}/paged?#{query_string}")
  end

  @doc """
  Find a specific exchange account by its ID.

  - `exchange_id`: The ID of the exchange account to retrieve
  """
  def get_account(exchange_id) when is_binary(exchange_id) do
    get!("#{@base_path}/#{exchange_id}")
  end

  @transfer_schema [
    exchangeId: [
      type: :string,
      required: true,
      doc: "The ID of the exchange account to transfer from"
    ],
    asset: [type: :string, required: true, doc: "The asset to transfer"],
    amount: [type: :string, required: true, doc: "The amount to transfer"],
    sourceType: [
      type: {:in, @trading_account_type},
      required: true,
      doc:
        "The source trading account type. One of `:coin_futures`, `:coin_margined_swap`, `:exchange`, `:funding`, `:fundable`, `:futures`, `:futures_cross`, `:margin`, `:margin_cross`, `:options`, `:spot`, `:usdt_margined_swap_cross`, `:usdt_futures`, `:unified`"
    ],
    destType: [
      type: {:in, @trading_account_type},
      required: true,
      doc:
        "The destination trading account type. One of `:coin_futures`, `:coin_margined_swap`, `:exchange`, `:funding`, `:fundable`, `:futures`, `:futures_cross`, `:margin`, `:margin_cross`, `:options`, `:spot`, `:usdt_margined_swap_cross`, `:usdt_futures`, `:unified`"
    ]
  ]

  @doc """
  Transfer funds between trading accounts on the same exchange account.

  ```
  FireblocksSdk.Api.ExchangeAccount.transfer([
    exchangeId: "binance-account-id",
    asset: "BTC",
    amount: "0.5",
    sourceType: :spot,
    destType: :futures
  ])
  ```

  Options:\n#{NimbleOptions.docs(@transfer_schema)}
  """
  def transfer(opts, idempotent_key \\ "") do
    {:ok, options} = NimbleOptions.validate(opts, @transfer_schema)
    exchange_id = options[:exchangeId]

    params =
      options
      |> Keyword.delete(:exchangeId)
      |> atom_to_upper([:sourceType, :destType])
      |> Enum.into(%{})
      |> Jason.encode!()

    post!("#{@base_path}/#{exchange_id}/internal_transfer", params, idempotent_key)
  end

  @convert_schema [
    exchangeId: [
      type: :string,
      required: true,
      doc: "The ID of the exchange account to convert assets on"
    ],
    amount: [type: :string, required: true, doc: "The amount to convert"],
    srcAsset: [type: :string, required: true, doc: "The source asset to convert from"],
    destAsset: [type: :string, required: true, doc: "The destination asset to convert to"]
  ]

  @doc """
  Convert assets on an exchange account.

  ```
  FireblocksSdk.Api.ExchangeAccount.convert([
    exchangeId: "binance-account-id",
    amount: "100",
    srcAsset: "USDT",
    destAsset: "BTC"
  ])
  ```

  Options:\n#{NimbleOptions.docs(@convert_schema)}
  """
  def convert(opts, idempotent_key \\ "") do
    {:ok, options} = NimbleOptions.validate(opts, @convert_schema)
    exchange_id = options[:exchangeId]

    params =
      options
      |> Keyword.delete(:exchangeId)
      |> Enum.into(%{})
      |> Jason.encode!()

    post!("#{@base_path}/#{exchange_id}/convert", params, idempotent_key)
  end
end
