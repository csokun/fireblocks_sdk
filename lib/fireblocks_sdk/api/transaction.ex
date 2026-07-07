defmodule FireblocksSdk.Api.Transaction do
  import FireblocksSdk.Request

  @base_path "/v1/transactions"

  # ---------------------------------------------------------------------------
  # Shared type helpers (used across multiple schemas below)
  # ---------------------------------------------------------------------------

  @transaction_status [
    :submitted,
    :queued,
    :pending_signature,
    :pending_authorization,
    :pending_3rd_party_manual_approval,
    :pending_3rd_party,
    :broadcasting,
    :confirming,
    :completed,
    :pending_aml_screening,
    :partially_completed,
    :cancelling,
    :cancelled,
    :rejected,
    :failed,
    :timeout,
    :blocked
  ]

  @peer_type [
    :vault_account,
    :exchange_account,
    :internal_wallet,
    :external_wallet,
    :unknown,
    :network_connection,
    :fiat_account,
    :compound,
    :one_time_address,
    :oec_partner
  ]

  @peer [
    type: {:in, @peer_type},
    doc:
      "one of `:vault_account`, `:exchange_account`, `:internal_wallet`, `:external_wallet`, `:unknown`, `:network_connection`, `:fiat_account`, `:compound`, `:one_time_address`, `:oec_partner`"
  ]

  @fee_level [:high, :medium, :low]

  @virtual_type [:off_exchange, :default, :oec_fee_bank]

  # ---------------------------------------------------------------------------
  # Schemas
  # ---------------------------------------------------------------------------

  @list_schema [
    before: [
      type: :string,
      doc:
        "Unix timestamp in milliseconds. Returns only transactions created before the specified date"
    ],
    after: [
      type: :string,
      doc:
        "Unix timestamp in milliseconds. Returns only transactions created after the specified date"
    ],
    status: [
      type: {:in, @transaction_status},
      doc:
        "available values `:submitted`, `:queued`, `:pending_signature`, `:pending_authorization`, `:pending_3rd_party_manual_approval`, `:pending_3rd_party`, `:broadcasting`, `:confirming`, `:completed`, `:pending_aml_screening`, `:partially_completed`, `:cancelling`, `:cancelled`, `:rejected`, `:failed`, `:timeout`, `:blocked`"
    ],
    orderBy: [
      type: {:in, [:createdAt, :lastUpdated]},
      doc: "available values `:createdAt`, `:lastUpdated`"
    ],
    sort: [type: {:in, [:asc, :desc]}, doc: "one of `:asc` or `:desc`"],
    limit: [
      type: :integer,
      doc:
        "Limits the number of results. If not provided, a limit of 200 will be used. The maximum allowed limit is 500"
    ],
    txHash: [type: :string, doc: "Returns only results with a specified txHash"],
    assets: [type: :string, doc: "A list of assets to filter by, seperated by commas"],
    sourceType: @peer,
    destType: @peer,
    sourceId: [type: :string],
    destId: [type: :string, doc: "The destination ID of the transaction"],
    sourceWalletId: [
      type: :string,
      doc: "Returns only results where the source is a specific end user wallet"
    ],
    destWalletId: [
      type: :string,
      doc: "Returns only results where the destination is a specific end user wallet"
    ],
    next: [type: :string, doc: "Retrieve the next page of results"],
    prev: [type: :string, doc: "Retrieve the previous page of results"]
  ]

  @create_schema [
    assetId: [type: :string],
    source: [
      type: :map,
      keys: [
        type: @peer,
        id: [type: :string],
        virtualId: [type: :string],
        virtualType: [type: {:in, @virtual_type}],
        address: [type: :string]
      ]
    ],
    destination: [
      type: :map,
      keys: [
        type: @peer,
        id: [type: :string],
        virtualId: [type: :string],
        virtualType: [type: {:in, @virtual_type}],
        oneTimeAddress: [
          type: :map,
          keys: [
            address: [type: :string],
            tag: [type: :string]
          ]
        ]
      ]
    ],
    amount: [
      type: :string,
      doc: "For **TRANSFER** operations, the requested amount to transfer, in the asset's unit."
    ],
    operation: [
      type:
        {:in,
         [
           :transfer,
           :mint,
           :burn,
           :contract_call,
           :program_call,
           :typed_message,
           :raw,
           :approve,
           :enable_asset
         ]},
      doc:
        "available value `:transfer`, `:mint`, `:burn`, `:contract_call`, `:program_call`, `:raw`, `:typed_message`, `:approve`, `:enable_asset`"
    ],
    fee: [type: :string],
    feeLevel: [
      type: {:in, @fee_level},
      doc:
        "For UTXO or EVM-based blockchains only. Defines the blockchain fee level which will be payed for the transaction. Alternatively, specific fee estimation parameters exist below."
    ],
    failOnLowFee: [type: :boolean],
    maxFee: [type: :string],
    priorityFee: [type: :string],
    gasPrice: [
      type: :string,
      doc: """
      For non-EIP-1559, EVM-based transactions. Price per gas unit (in Ethereum this is specified in Gwei).

      **Note:** Only two of the three arguments can be specified in a single transaction: gasLimit, gasPrice and networkFee. Fireblocks recommends using a numeric string for accurate precision. Although a number input exists, it is deprecated.
      """
    ],
    gasLimit: [type: :string],
    note: [type: :string],
    cpuStaking: [type: :integer],
    networkStaking: [type: :integer],
    autoStaking: [type: :boolean],
    customerRefId: [type: :string],
    extraParameters: [type: :map],
    destinations: [
      type: :map,
      keys: [
        amount: [type: :string],
        destination: [
          type: :map,
          keys: [
            type: [type: {:in, @peer_type}],
            id: [type: :string],
            oneTimeAddress: [
              type: :map,
              keys: [
                address: [type: :string],
                tag: [type: :string]
              ]
            ]
          ]
        ]
      ]
    ],
    replaceTxByHash: [
      type: :string,
      doc:
        "For EVM-based blockchains only. In case a transaction is stuck, specify the hash of the stuck transaction to replace it by this transaction with a higher fee, or to replace it with this transaction with a zero fee and drop it from the blockchain."
    ],
    externalTxId: [type: :string],
    treatAsGrossAmount: [
      type: :boolean,
      doc: """
      When set to true, the fee will be deducted from the requested amount.

      **Note:** This parameter can only be considered if a transaction's asset is a base asset, such as ETH or MATIC. If the asset can't be used for transaction fees, like USDC, this parameter is ignored and the fee is deducted from the relevant base asset wallet in the source account.
      """
    ],
    forceSweep: [
      type: :boolean,
      doc: """
      For Polkadot, Kusama and Westend transactions only. When set to true, Fireblocks will empty the asset wallet.

      **Note:** If set to true when the source account is exactly 1 DOT, the transaction will fail. Any amount more or less than 1 DOT succeeds. This is a Polkadot blockchain limitation.
      """
    ],
    feePayerInfo: [
      type: :map,
      keys: [
        feePayerAccountId: [type: :string]
      ]
    ],
    travelRuleMessageId: [type: :string],
    useGasless: [type: :boolean]
  ]

  @drop_schema [
    txId: [type: :string, required: true],
    feeLevel: [type: {:in, @fee_level}],
    gasFee: [type: :string]
  ]

  @set_confirmation_threshold_schema [
    type: [type: {:in, [:txId, :txHash]}, doc: "available value `:txId`, `:txHash`"],
    id: [type: :string, doc: "Fireblocks transaction id or blockchain transaction hash"],
    numOfConfirmations: [type: :integer, default: 0]
  ]

  # ---------------------------------------------------------------------------
  # Functions
  # ---------------------------------------------------------------------------

  @doc """
  Gets the estimated required fee for an asset.
  Fireblocks fetches, calculates and caches the result every 30 seconds.

  Customers should query this API while taking the caching interval into consideration.

  **Options:**

  - `asset`: The asset for which to estimate the fee

  Notes:

  - The `networkFee` parameter is the `gasPrice` with a given delta added, multiplied by the gasLimit plus the delta. - The estimation provided depends on the asset type.

  - For UTXO-based assets, the response contains the `feePerByte` parameter
  - For ETH-based and all EVM based assets, the response will contain `gasPrice` parameter. This is calculated by adding the `baseFee` to the `actualPriority` based on the latest 12 blocks. The response for ETH-based  contains the `baseFee`, `gasPrice`, and `priorityFee` parameters.
  - For ADA-based assets, the response will contain the parameter `networkFee` and `feePerByte` parameters.
  - For XRP and XLM, the response will contain the transaction fee.
  - For other assets, the response will contain the `networkFee` parameter.

  Learn more about Fireblocks Fee Management in the following [guide](https://developers.fireblocks.com/reference/estimate-transaction-fee).

  **Endpoint Permission**: Admin, Non-Signing Admin, Signer, Approver, Editor.
  """
  def get_asset_fee(asset) when is_binary(asset) do
    get!("/v1/estimate_network_fee?assetId=#{asset}")
  end

  @doc """
  List all transactions

  ```
  FireblocksSdk.Api.Transaction.list([
    status: :rejected,
    sourceType: :vault_account,
    sourceId: "1",
    limit: 10
  ])
  ```

  Options:\n#{NimbleOptions.docs(@list_schema)}
  """
  def list(filter) do
    {:ok, params} = NimbleOptions.validate(filter, @list_schema)

    query_string =
      params
      |> atom_to_upper([:status, :sourceType, :destType, :sort])
      |> atom_to_string([:orderBy])
      |> URI.encode_query()

    [_, data, headers] = FireblocksSdk.Request.get("#{@base_path}?#{query_string}")

    pages =
      Enum.reduce(headers, %{next: nil, prev: nil}, fn
        {"next-page", url}, acc ->
          next = extract_query(url) |> Map.get("next")
          Map.put(acc, :next, next)

        {"prev-page", url}, acc ->
          prev = extract_query(url) |> Map.get("prev")
          Map.put(acc, :prev, prev)

        _, acc ->
          acc
      end)

    %{transactions: data, next: pages.next, previous: pages.prev}
  end

  @doc """
  Creates a new transaction with the specified options

  ```
  FireblocksSdk.Api.Transaction.create([
    assetId: "ETH",
    operation: :transfer, # :mint | :burn | :raw
    source: %{
      type: :vault_account,
      id: "1"
    },
    destination: %{
      type: :vault_account,
      id: "2"
    },
    amount: "0.005",
    note: "donation!"
  ])
  ```

  Supported options:\n#{NimbleOptions.docs(@create_schema)}
  """
  def create(transaction, idempotent_key \\ "") do
    params = parse_transaction_creation_request(transaction)
    post!("#{@base_path}", params, idempotent_key)
  end

  @doc """
  Estimates the transaction fee for a transaction request.

  Note: Supports all Fireblocks assets except ZCash (ZEC).
  """
  def estimate_fee(transaction, idempotent_key \\ "") do
    params = parse_transaction_creation_request(transaction)
    post!("#{@base_path}/estimate_fee", params, idempotent_key)
  end

  @doc """
  Returns a transaction by ID.

  - `txId`: Fireblocks transaction id
  """
  def get(txId) when is_binary(txId) do
    get!("#{@base_path}/#{txId}")
  end

  @doc """
  Returns transaction by external transaction ID.

  - `externalTxId`: The external ID of the transaction to return
  """
  def get_external_tx_id(exteralTxId) when is_binary(exteralTxId) do
    get!("#{@base_path}/external_tx_id/#{exteralTxId}/")
  end

  @doc """
  Overrides the required number of confirmations for transaction completion by transaction ID.

  Options:\n#{NimbleOptions.docs(@set_confirmation_threshold_schema)}
  """
  def set_confirmation_threshold(threshold, idempotencyKey \\ "") do
    {:ok, options} =
      NimbleOptions.validate(threshold, @set_confirmation_threshold_schema)

    id = options[:id]

    endpoint =
      case options[:type] do
        :txId -> "#{@base_path}/#{id}/set_confirmation_threshold"
        :txHash -> "/v1/txHash/#{id}/set_confirmation_threshold"
      end

    params = %{numOfConfirmations: options[:numOfConfirmations]} |> Jason.encode!()
    post!(endpoint, params, idempotencyKey)
  end

  @doc """
  Drops a stuck ETH transaction and creates a replacement transaction.

  ```
    FireblocksSdk.Api.Transaction.drop([
      txId: "fireblock-tx-id",
      feeLevel: :medium,
      gasFee: ""
    ])
  ```

  Options:\n#{NimbleOptions.docs(@drop_schema)}
  """
  def drop(tx_drop_req, idempotencyKey \\ "") do
    {:ok, options} = NimbleOptions.validate(tx_drop_req, @drop_schema)

    params =
      options
      |> atom_to_upper([:feeLevel])
      |> Jason.encode!()

    post!("#{@base_path}/#{options[:txId]}/drop", params, idempotencyKey)
  end

  @doc """
  Cancels a transaction by ID.

  - `txId`: Fireblocks transaction id
  """
  def cancel(txId, idempotencyKey \\ "") when is_binary(txId) do
    post!("#{@base_path}/#{txId}/cancel", "", idempotencyKey)
  end

  @doc """
  Freezes a transaction by ID.

  - `txId`: Fireblocks transaction id
  """
  def freeze(txId, idempotencyKey \\ "") when is_binary(txId) do
    post!("#{@base_path}/#{txId}/freeze", "", idempotencyKey)
  end

  @doc """
  Unfreezes a transaction by ID and makes the transaction available again.

  - `txId`: Fireblocks transaction id
  """
  def unfreeze(txId, idempotencyKey \\ "") when is_binary(txId) do
    post!("#{@base_path}/#{txId}/unfreeze", "", idempotencyKey)
  end

  defp parse_transaction_creation_request(args) do
    {:ok, options} = NimbleOptions.validate(args, @create_schema)

    options
    |> atom_to_upper([
      [:source, :type],
      [:source, :virtualType],
      [:destination, :type],
      [:destination, :virtualType],
      [:destinations, :destination, :type],
      [:operation],
      [:feeLevel]
    ])
    |> Enum.into(%{})
    |> Jason.encode!()
  end

  defp extract_query(url) do
    url
    |> URI.parse()
    |> Map.get(:query, "")
    |> URI.decode_query()
  end
end
