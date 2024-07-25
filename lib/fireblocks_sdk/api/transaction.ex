defmodule FireblocksSdk.Api.Transaction do
  alias FireblocksSdk.Schema

  import FireblocksSdk.Request

  @base_path "/v1/transactions"

  @doc """
  Gets the estimated required fee for an asset. For UTXO based assets, the response will contain the suggested fee per byte, for ETH/ETC based assets, the suggested gas price, and for XRP/XLM, the transaction fee.

  - `asset`: The asset for which to estimate the fee
  """
  def get_asset_fee(asset) when is_binary(asset) do
    get!("#{@base_path}?asset=#{asset}")
  end

  @doc """
  List all transactions

  ```
  FireblocksSdk.Api.Transaction.transactions([
    status: :rejected, 
    sourceType: :vault_account,
    sourceId: "1",
    limit: 10
  ])
  ```

  Options: \n#{NimbleOptions.docs(Schema.transaction_filter())}
  """
  def transactions(filter) do
    {:ok, params} = NimbleOptions.validate(filter, Schema.transaction_filter())

    query_string =
      params
      |> atom_to_upper([:status, :sourceType, :destType])
      |> atom_to_string([:orderBy])
      |> URI.encode_query()

    get!("#{@base_path}?#{query_string}")
  end

  @doc """
  Creates a new transaction with the specified options

  ```
  FireblocksSdk.Api.Transaction.create_transaction([
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

  Supported options:\n#{NimbleOptions.docs(Schema.create_transaction_request())}
  """
  def create_transaction(transaction, idempotent_key \\ "") do
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
  def get_transaction_by_id(txId) when is_binary(txId) do
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

  Options:\n#{NimbleOptions.docs(Schema.transaction_set_confirmation_request())}
  """
  def set_confirmation_threshold(threshold, idempotencyKey \\ "") do
    {:ok, options} =
      NimbleOptions.validate(threshold, Schema.transaction_set_confirmation_request())

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

  Options: \n#{NimbleOptions.docs(Schema.transaction_drop_request())}
  """
  def drop(tx_drop_req, idempotencyKey \\ "") do
    {:ok, options} = NimbleOptions.validate(tx_drop_req, Schema.transaction_drop_request())

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
    {:ok, options} = NimbleOptions.validate(args, Schema.create_transaction_request())

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
end
