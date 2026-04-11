defmodule FireblocksSdk.Api.ContractInteractions do
  import FireblocksSdk.Request

  @interactions "/v1/contract_interactions/base_asset_id"

  @get_functions_schema [
    baseAssetId: [type: :string, required: true, doc: "Base assetId e.g ETH, ETH_TEST5"],
    contractAddress: [type: :string, required: true]
  ]

  @doc """
  Return deployed contract's ABI by blockchain native asset id and contract address

  Options:\n#{NimbleOptions.docs(@get_functions_schema)}
  """
  def get_functions(options) do
    {:ok, params} = NimbleOptions.validate(options, @get_functions_schema)

    get!(
      "#{@interactions}/#{params[:baseAssetId]}/contract_address/#{params[:contractAddress]}/functions"
    )
  end

  @read_schema [
    baseAssetId: [type: :string, required: true, doc: "Base assetId e.g ETH, ETH_TEST5"],
    contractAddress: [type: :string, required: true],
    abiFunction: [type: :map]
  ]

  @doc """
  Return deployed contract's ABI by blockchain native asset id and contract address

  Options:\n#{NimbleOptions.docs(@read_schema)}
  """
  def read(options, idempotentKey \\ "") do
    {:ok, params} = NimbleOptions.validate(options, @read_schema)
    baseAssetId = params[:baseAssetId]
    contractAddress = params[:contractAddress]

    params =
      params
      |> Keyword.delete(:baseAssetId)
      |> Keyword.delete(:contractAddress)
      |> Enum.into(%{})
      |> Jason.encode!()

    post!(
      "#{@interactions}/#{baseAssetId}/contract_address/#{contractAddress}/functions/read",
      params,
      idempotentKey
    )
  end

  @write_schema [
    baseAssetId: [type: :string, required: true, doc: "Base assetId e.g ETH, ETH_TEST5"],
    contractAddress: [type: :string, required: true],
    vaultId: [
      type: :string,
      required: true,
      doc: "The vault account id this contract was deploy from"
    ],
    abiFunction: [type: :map],
    amount: [type: :string, doc: "Amount in base asset. Being used in payable functions"],
    feeLevel: [
      type: {:in, [:low, :medium, :high]},
      default: :medium,
      doc: "Fee level for the write function transaction. interchangeable with the 'fee' field"
    ],
    fee: [
      type: :string,
      doc:
        "Max fee amount for the write function transaction. interchangeable with the 'feeLevel' field"
    ],
    note: [
      type: :string,
      doc:
        "Custom note, not sent to the blockchain, that describes the transaction at your Fireblocks workspace"
    ],
    useGasless: [type: :boolean, default: false],
    externalId: [
      type: :string,
      doc:
        "External id that can be used to identify the transaction in your system. The unique identifier of the transaction outside of Fireblocks with max length of 255 characters"
    ]
  ]

  @doc """
  Call a write function on a deployed contract by blockchain native asset id and contract address. This creates an onchain transaction, thus it is an async operation. It returns a transaction id that can be polled for status check

  Options:\n#{NimbleOptions.docs(@write_schema)}
  """
  def write(options, idempotentKey \\ "") do
    {:ok, params} = NimbleOptions.validate(options, @write_schema)
    baseAssetId = params[:baseAssetId]
    contractAddress = params[:contractAddress]

    params =
      params
      |> Keyword.delete(:baseAssetId)
      |> Keyword.delete(:contractAddress)
      |> atom_to_upper([:feeLevel])
      |> Enum.into(%{})
      |> Jason.encode!()

    post!(
      "#{@interactions}/#{baseAssetId}/contract_address/#{contractAddress}/functions/write",
      params,
      idempotentKey
    )
  end

  @get_transaction_receipt_schema [
    baseAssetId: [type: :string, required: true, doc: "Base assetId e.g ETH, ETH_TEST5"],
    txHash: [type: :string, required: true, doc: "Transaction hash"]
  ]

  @doc """
  Retrieve the transaction receipt by blockchain native asset ID and transaction hash

  Options:\n#{NimbleOptions.docs(@get_transaction_receipt_schema)}
  """
  def get_transaction_receipt(receipt) do
    {:ok, params} = NimbleOptions.validate(receipt, @get_transaction_receipt_schema)

    get!("#{@interactions}/#{params[:baseAssetId]}/tx_hash/#{params[:txHash]}/receipt")
  end

  @doc """
  Get the contract address deployed by a transaction, identified by blockchain native asset ID
  and transaction hash.

  - `base_asset_id`: Base asset ID of the blockchain (e.g. `"ETH"`, `"ETH_TEST5"`)
  - `tx_hash`: The transaction hash that deployed the contract
  """
  def get_contract_address(base_asset_id, tx_hash)
      when is_binary(base_asset_id) and is_binary(tx_hash) do
    get!("#{@interactions}/#{base_asset_id}/tx_hash/#{tx_hash}")
  end

  @decode_schema [
    baseAssetId: [type: :string, required: true, doc: "Base assetId e.g ETH, ETH_TEST5"],
    contractAddress: [type: :string, required: true],
    dataType: [
      type: {:in, [:error, :log, :function]},
      doc: "Available values: `:error`, `:log`, `:function`"
    ],
    data: [
      type: :map,
      doc:
        "The data to decode, which can be a string or an object containing the data and its type."
    ],
    abi: [type: {:list, :map}, doc: "The abi of the function/error/log to decode."]
  ]

  @doc """
  Decode a function call data, error, or event log from a deployed contract by blockchain native asset id and contract address.

  Options:\n#{NimbleOptions.docs(@decode_schema)}
  """
  def decode(options, idempotentKey \\ "") do
    {:ok, params} = NimbleOptions.validate(options, @decode_schema)
    baseAssetId = params[:baseAssetId]
    contractAddress = params[:contractAddress]

    params =
      params
      |> Keyword.delete(:baseAssetId)
      |> Keyword.delete(:contractAddress)
      |> atom_to_upper([:dataType])
      |> Enum.into(%{})
      |> Jason.encode!()

    post!(
      "#{@interactions}/#{baseAssetId}/contract_address/#{contractAddress}/decode",
      params,
      idempotentKey
    )
  end
end
