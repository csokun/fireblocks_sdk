defmodule FireblocksSdk.Api.Tokenization do
  import FireblocksSdk.Request

  @base_path "/v1/tokenization"

  @list_schema [
    pageCursor: [type: :string],
    pageSize: [type: :non_neg_integer, default: 10],
    status: [type: :string, default: "COMPLETED"]
  ]

  @doc """
  Return all linked tokens (paginated)

  Options:\n#{NimbleOptions.docs(@list_schema)}
  """
  def list(filter) do
    {:ok, params} = NimbleOptions.validate(filter, @list_schema)
    query = params |> URI.encode_query()
    get!("#{@base_path}/tokens?#{query}")
  end

  @doc """
    Return a linked token, with its status and metadata.
  """
  def get(token_id) do
    get!("#{@base_path}/tokens/#{token_id}")
  end

  @create_schema [
    blockchainId: [type: :string],
    assetId: [type: :string],
    vaultAccountId: [
      type: :string,
      required: true,
      doc: "The id of the vault account that initiated the request to issue the token"
    ],
    createParams: [type: :any, required: true],
    displayName: [type: :string],
    useGasless: [type: :boolean],
    fee: [type: :string],
    feeLevel: [type: :string]
  ]

  @doc """
  Facilitates the creation of a new token, supporting both EVM-based and Stellar/Ripple platforms.
  For EVM, it deploys the corresponding contract template to the blockchain and links the token to the workspace.
  For Stellar/Ripple, it links a newly created token directly to the workspace without deploying a contract.
  Returns the token link with status "PENDING" until the token is deployed or "SUCCESS" if no deployment is needed.

  Options:\n#{NimbleOptions.docs(@create_schema)}
  """
  def create(params, idempotentKey \\ "") do
    {:ok, params} = NimbleOptions.validate(params, @create_schema)
    data = params |> Enum.into(%{}) |> Jason.encode!()
    post!("#{@base_path}/tokens", data, idempotentKey)
  end

  @link_schema [
    type: [
      type: {:in, [:fungible, :non_fungible_token, :token_utility, :token_extension]},
      required: true,
      doc:
        "The type of token being link. Available values: `:fungible`, `:non_fungible_token`, `:token_utility`, `:token_extension`"
    ],
    refId: [
      type: :string,
      doc:
        "The Fireblocks' token link reference id. For example, 'BQ5R_BDESC_ABC' if it's a fungible asset"
    ],
    displayName: [
      type: :string,
      doc: "The token display name"
    ],
    baseAssetId: [type: :string, doc: "The blockchain base assetId"],
    contractAddress: [type: :string, doc: "The contract's onchain address"]
  ]

  @doc """
  Link an existing token to the workspace.

  Options:\n#{NimbleOptions.docs(@link_schema)}
  """
  def link(link_req, idempotentKey \\ "") do
    {:ok, params} = NimbleOptions.validate(link_req, @link_schema)

    params =
      params
      |> atom_to_upper([:type])
      |> Enum.into(%{})
      |> Jason.encode!()

    post!("#{@base_path}/tokens/link", params, idempotentKey)
  end

  @doc """
  Unlink a token. The token will be unlinked from the workspace. The token will not be deleted on chain nor the refId, only the link to the workspace will be removed.
  """
  def unlink(link_id) when is_binary(link_id) do
    delete!("#{@base_path}/tokens/#{link_id}")
  end

  @doc """
  Return a linked token, with its status and metadata.
  """
  def get_link(link_id) when is_binary(link_id) do
    get!("#{@base_path}/tokens/#{link_id}")
  end

  @get_deterministic_address_schema [
    chainDescriptor: [
      type: :string,
      required: true,
      doc:
        "The base asset identifier of the blockchain (legacyId) to calculate deterministic address. Example: 'ETH'"
    ],
    templateId: [
      type: :string,
      required: true,
      doc: "The template identifier (UUID). Example: 'b70701f4-d7b1-4795-a8ee-b09cdb5b850d'"
    ],
    initParams: [
      type: {:list, :map},
      required: true,
      doc:
        "The deploy function parameters and values of the contract template. See ParameterWithValue schema."
    ],
    salt: [
      type: :string,
      required: true,
      doc:
        "The salt to calculate the deterministic address. Must be a number between 0 and 2^256 -1, for it to fit in the bytes32 parameter. Example: '123456789'"
    ]
  ]

  @doc """
  Get a deterministic address for contract deployment. The address is derived from the contract's bytecode and provided salt. This endpoint is used to get the address of a contract that will be deployed in the future.

  Options:\n#{NimbleOptions.docs(@get_deterministic_address_schema)}
  """
  def get_deterministic_address(params, idempotentKey \\ "") do
    {:ok, params} = NimbleOptions.validate(params, @get_deterministic_address_schema)
    data = params |> Enum.into(%{}) |> Jason.encode!()
    post!("#{@base_path}/multichain/deterministic_address", data, idempotentKey)
  end

  def templates() do
    get!("#{@base_path}/templates")
  end

  def get_template(id) do
    get!("#{@base_path}/templates/#{id}")
  end

  @transfers_schema [
    id: [type: :string, required: true, doc: "The token link id"],
    startDate: [type: :string, doc: "Start date of the time range in ISO 8601 format"],
    endDate: [type: :string, doc: "End date of the time range in ISO 8601 format"],
    pageCursor: [type: :string, doc: "Page cursor to get the next page"],
    pageSize: [type: :non_neg_integer, default: 10],
    sortBy: [
      type: {:in, [:blockTimeStamp]},
      default: :blockTimeStamp,
      doc: "Sorting field for transfers"
    ],
    order: [type: {:in, [:asc, :desc]}, default: :desc],
    sender: [type: :string, doc: "Filter transfers by sender address"],
    receiver: [type: :string, doc: "Filter transfers by receiver address"]
  ]

  @doc """
  Returns a paginated list of ERC20 transfer events for the token contract, optionally filtered by date range.

  ```
  FireblocksSdk.Api.Tokenization.transfers([
    id: fbfbfbfb-fbfb-fbfb-fbfb-fbfbfbfbfbfb
  ])
  ```

  Options:\n#{NimbleOptions.docs(@transfers_schema)}
  """
  def transfers(opts) do
    {:ok, options} = NimbleOptions.validate(opts, @transfers_schema)
    id = options[:id]

    query_string =
      options
      |> Keyword.delete(:id)
      |> atom_to_string([:sortBy])
      |> atom_to_upper([:order])
      |> Enum.into(%{})
      |> URI.encode_query()

    get!("#{@base_path}/tokens/#{id}/transfers?#{query_string}")
  end

  @doc """
  Returns a paginated list of onchain transactions for the token contract, optionally filtered by date range.

  ```
  FireblocksSdk.Api.Tokenization.transactions([
    id: fbfbfbfb-fbfb-fbfb-fbfb-fbfbfbfbfbfb
  ])
  ```

  Options:\n#{NimbleOptions.docs(@transfers_schema)}
  """
  def transactions(opts) do
    {:ok, options} = NimbleOptions.validate(opts, @transfers_schema)
    id = options[:id]

    query_string =
      options
      |> Keyword.delete(:id)
      |> atom_to_string([:sortBy])
      |> atom_to_upper([:order])
      |> Enum.into(%{})
      |> URI.encode_query()

    get!("#{@base_path}/tokens/#{id}/transfers?#{query_string}")
  end

  @doc """
  Returns a list of currently active roles for the token contract.
  """
  def rbac(token_id) do
    get!("#{@base_path}/tokens/#{token_id}/rbac")
  end

  @token_balances [
    id: [type: :string, required: true, doc: "The token link id"],
    pageCursor: [type: :string, doc: "Page cursor to get the next page"],
    pageSize: [type: :non_neg_integer, default: 10],
    sortBy: [
      type: {:in, [:blockTimestamp, :accountAddress]},
      default: :blockTimestamp,
      doc: "Sorting field for transfers"
    ],
    order: [type: {:in, [:asc, :desc]}, default: :desc]
  ]
  @doc """
  Returns the latest balance for each unique address holding this token.

  ```
  FireblocksSdk.Api.Tokenization.balances([
    id: fbfbfbfb-fbfb-fbfb-fbfb-fbfbfbfbfbfb
  ])
  ```

  Options:\n#{NimbleOptions.docs(@token_balances)}
  """
  def balances(opts) do
    {:ok, options} = NimbleOptions.validate(opts, @token_balances)
    id = options[:id]

    query_string =
      options
      |> Keyword.delete(:id)
      |> atom_to_string([:sortBy])
      |> atom_to_upper([:order])
      |> Enum.into(%{})
      |> URI.encode_query()

    get!("#{@base_path}/tokens/#{id}/balances?#{query_string}")
  end

  @doc """
  Get the total count of linked tokens
  """
  def count(), do: get!("#{@base_path}/tokens/count")

  @doc """
  Returns the total number of unique holders and the total supply for the token contract.
  """
  def summary(token_id), do: get!("#{@base_path}/tokens/#{token_id}/summary")

  @doc """
  Returns the latest token balance for the specified account address.
  """
  def balance(token_id, wallet), do: get!("#{@base_path}/tokens/#{token_id}/balances/#{wallet}")

  @balance_history_schema [
    id: [type: :string, required: true, doc: "The token link id"],
    accountAddress: [
      type: :string,
      required: true,
      doc: "The account address to get balance history for"
    ],
    startDate: [type: :string, doc: "Start date of the time range in ISO 8601 format"],
    endDate: [type: :string, doc: "End date of the time range in ISO 8601 format"],
    interval: [
      type: {:in, [:hour, :day, :week, :month]},
      default: :day,
      doc: "Time interval for grouping data"
    ],
    pageCusor: [type: :string, doc: "Page cursor to get the next page"],
    pageSize: [
      type: :non_neg_integer,
      doc: "Number of items per page (max 100), requesting more than 100 will return 100 items",
      default: 10
    ],
    sortBy: [
      type: {:in, [:blockTimestamp]},
      default: :blockTimestamp,
      doc: "Sorting only supported by 'blockTimestamp'"
    ],
    order: [type: {:in, [:asc, :desc]}, default: :desc, doc: "ASC / DESC ordering (default DESC)"]
  ]
  @doc """
  Returns paginated balance history for the specified account address with optional time-range filtering.

  Options:\n#{NimbleOptions.docs(@balance_history_schema)}
  """
  def balance_history(opts) do
    {:ok, options} = NimbleOptions.validate(opts, @token_balances)
    token_id = options[:id]
    accountAddress = options[:accountAddress]

    query_string =
      options
      |> Keyword.delete(:id)
      |> Keyword.delete(:accountAddress)
      |> atom_to_string([:sortBy])
      |> atom_to_upper([:order, :interval])
      |> Enum.into(%{})
      |> URI.encode_query()

    get!("#{@base_path}/tokens/#{token_id}/balances/#{accountAddress}/history?#{query_string}")
  end
end
