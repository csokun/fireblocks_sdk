defmodule FireblocksSdk.Api.Contract do
  import FireblocksSdk.Request

  @contract_endpoint "/v1/contracts"
  @interactions "/interactionss/baseAssetId"

  @add_asset_schema [
    contractId: [type: :string, require: true],
    assetId: [type: :string, require: true],
    address: [type: :string, require: true],
    tag: [type: :string]
  ]

  @doc """
  Gets a list of contracts.
  """
  def list() do
    get!(@contract_endpoint)
  end

  @doc """
  Creates a new contract.
  """
  def create(name, idempotent_key \\ "") do
    contract = %{name: name} |> Jason.encode!()
    post!(@contract_endpoint, contract, idempotent_key)
  end

  @doc """
  Returns a contract by id.
  """
  def get(contract_id) do
    get!("#{@contract_endpoint}/#{contract_id}")
  end

  @doc """
  Delete a contract
  """
  def delete(contract_id) do
    delete!("#{@contract_endpoint}/#{contract_id}")
  end

  @doc """
  Returns a contract asset by ID.
  """
  def find_contract_asset(contract_id, asset_id) do
    get!("#{@contract_endpoint}/#{contract_id}/assets/#{asset_id}")
  end

  @doc """
  Adds an asset to an existing contract.

  ```
    FireblocksSdk.Api.Contract.add_asset([
      contractId: "CONTRACT_ID",
      assetId: "ASSET_ID",
      address: "ADDRESS",
    ])
  ```

  Options:\n#{NimbleOptions.docs(@add_asset_schema)}
  """
  def add_asset(contract_asset, idempotent_key \\ "") do
    {:ok, options} = NimbleOptions.validate(contract_asset, @add_asset_schema)
    contract_id = options[:contractId]
    asset_id = options[:assetId]

    params =
      options
      |> Keyword.delete(:contractId)
      |> Keyword.delete(:assetId)
      |> Jason.encode!()

    post!("#{@contract_endpoint}/#{contract_id}/assets/#{asset_id}", params, idempotent_key)
  end

  @doc """
  Delete a contract asset
  """
  def delete_asset(contract_id, asset_id) do
    delete!("#{@contract_endpoint}/#{contract_id}/assets/#{asset_id}")
  end

  @interaction_functions [
    baseAssetId: [type: :string, required: true, doc: "Base assetId e.g ETH, ETH_TEST5"],
    contractAddress: [type: :string, required: true]
  ]

  @doc """
  Return deployed contract's ABI by blockchain native asset id and contract address

  Options:\n#{NimbleOptions.docs(@interaction_functions)}
  """
  def get_functions(options) do
    {:ok, params} = NimbleOptions.validate(options, @interaction_functions)

    get!(
      "#{@interactions}/#{params[:baseAssetId]}/contract_address/#{params[:contractAddress]}/functions"
    )
  end

  @interaction_read [
    baseAssetId: [type: :string, required: true, doc: "Base assetId e.g ETH, ETH_TEST5"],
    contractAddress: [type: :string, required: true],
    abiFunction: [type: :map]
  ]
  @doc """
  Return deployed contract's ABI by blockchain native asset id and contract address

  Options:\n#{NimbleOptions.docs(@interaction_read)}
  """
  def read(options, idempotentKey \\ "") do
    {:ok, params} = NimbleOptions.validate(options, @interaction_read)
    baseAssetId = params[:baseAssetId]
    contractAddress = params[:contractAddress]

    params =
      params
      |> Keyword.delete(:baseAssetId)
      |> Keyword.delete(:contractAddress)
      |> Jason.encode!()

    post!(
      "#{@interactions}/#{baseAssetId}/contract_address/#{contractAddress}/functions",
      params,
      idempotentKey
    )
  end

  @interaction_write [
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

  Options:\n#{NimbleOptions.docs(@interaction_write)}
  """
  def write(options, idempotentKey \\ "") do
    {:ok, params} = NimbleOptions.validate(options, @interaction_read)
    baseAssetId = params[:baseAssetId]
    contractAddress = params[:contractAddress]

    params =
      params
      |> Keyword.delete(:baseAssetId)
      |> Keyword.delete(:contractAddress)
      |> Jason.encode!()

    post!(
      "#{@interactions}/#{baseAssetId}/contract_address/#{contractAddress}/functions",
      params,
      idempotentKey
    )
  end

  @interaction_receipt [
    baseAssetId: [type: :string, required: true, doc: "Base assetId e.g ETH, ETH_TEST5"],
    txHash: [type: :string, required: true, doc: "Transaction hash"]
  ]

  @doc """
  Retrieve the transaction receipt by blockchain native asset ID and transaction hash

  Options:\n#{NimbleOptions.docs(@interaction_receipt)}
  """
  def get_transaction_receipt(receipt) do
    {:ok, params} = NimbleOptions.validate(receipt, @interaction_receipt)

    get!("#{@interactions}/#{params[:baseAssetId]}/tx_hash/#{params[:txHash]}/receipt")
  end

  @interaction_decode [
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

  Options:\n#{NimbleOptions.docs(@interaction_decode)}
  """
  def decode(options, idempotentKey \\ "") do
    {:ok, params} = NimbleOptions.validate(options, @interaction_decode)
    baseAssetId = params[:baseAssetId]
    contractAddress = params[:contractAddress]

    params =
      params
      |> Keyword.delete(:baseAssetId)
      |> Keyword.delete(:contractAddress)
      |> Jason.encode!()

    post!(
      "#{@interactions}/#{baseAssetId}/contract_address/#{contractAddress}/decode",
      params,
      idempotentKey
    )
  end
end
