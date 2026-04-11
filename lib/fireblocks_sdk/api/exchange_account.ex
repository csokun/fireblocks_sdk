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

  @exchange_type [
    :independent_reserve,
    :enclave_markets,
    :bit,
    :coinflex,
    :kucoin,
    :pxs,
    :liquid,
    :bithumb,
    :bitfinex,
    :bitso,
    :bitstamp,
    :kraken,
    :krakenintl,
    :binance,
    :binanceus,
    :cryptocom,
    :bybit_v2,
    :coinbasepro,
    :coinbaseprime,
    :coinbaseinternational,
    :whitebit,
    :coinbaseexchange,
    :korbit,
    :hitbtc,
    :gemini,
    :circle,
    :bitmex,
    :huobi,
    :deribit,
    :okcoin_v5,
    :okex,
    :coinmetro,
    :gateio,
    :scrypt,
    :coinhako,
    :lightbit,
    :bullish,
    :canvas_connect,
    :bitget,
    :luno,
    :bit_genera,
    :transfero
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

  @add_account_schema [
    exchangeType: [
      type: {:in, @exchange_type},
      required: true,
      doc: "The type of exchange account to add"
    ],
    name: [type: :string, required: true, doc: "Display name of the exchange account"],
    creds: [type: :string, doc: "Encrypted credentials"],
    key: [type: :string, doc: "API key of the exchange"],
    mainAccountId: [type: :string, doc: "Optional main account ID of the exchange"]
  ]

  @doc """
  Add an exchange account to the workspace.

  ```
  FireblocksSdk.Api.ExchangeAccount.add_account([
    exchangeType: :binance,
    name: "My Binance Account",
    key: "api-key-here"
  ])
  ```

  Options:\n#{NimbleOptions.docs(@add_account_schema)}
  """
  def add_account(opts, idempotent_key \\ "") do
    {:ok, options} = NimbleOptions.validate(opts, @add_account_schema)

    params =
      options
      |> atom_to_upper([:exchangeType])
      |> Enum.into(%{})
      |> Jason.encode!()

    post!(@base_path, params, idempotent_key)
  end

  @doc """
  Get the public key used to encrypt exchange account credentials.

  Returns the RSA public key that should be used to encrypt exchange API
  credentials before submitting them via `add_account/2`.
  """
  def get_credentials_public_key() do
    get!("#{@base_path}/credentials_public_key")
  end

  @doc """
  Get a specific asset on an exchange account.

  - `exchange_account_id`: The ID of the exchange account
  - `asset_id`: The asset ID (e.g. `"BTC"`, `"ETH"`)
  """
  def get_account_asset(exchange_account_id, asset_id)
      when is_binary(exchange_account_id) and is_binary(asset_id) do
    get!("#{@base_path}/#{exchange_account_id}/#{asset_id}")
  end
end
