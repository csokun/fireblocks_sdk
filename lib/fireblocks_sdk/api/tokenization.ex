defmodule FireblocksSdk.Api.Tokenization do
  alias FireblocksSdk.Schema

  import FireblocksSdk.Request

  @base_path "/v1/tokenization"

  @doc """
  Return all linked tokens (paginated)

  Options:\n#{NimbleOptions.docs(Schema.tokenization_list_request())}
  """
  def list(filter) do
    {:ok, params} = NimbleOptions.validate(filter, Schema.tokenization_list_request())
    query = params |> URI.encode_query()
    get!("#{@base_path}/tokens?#{query}")
  end

  @doc """
    Return a linked token, with its status and metadata.
  """
  def get(token_id) do
    get!("#{@base_path}/tokens/#{token_id}")
  end

  @doc """
  Facilitates the creation of a new token, supporting both EVM-based and Stellar/Ripple platforms.
  For EVM, it deploys the corresponding contract template to the blockchain and links the token to the workspace.
  For Stellar/Ripple, it links a newly created token directly to the workspace without deploying a contract.
  Returns the token link with status "PENDING" until the token is deployed or "SUCCESS" if no deployment is needed.

  Options:\n#{NimbleOptions.docs(Schema.tokenization_create_request())}
  """
  def create(params, idempotentKey \\ "") do
    {:ok, params} = NimbleOptions.validate(params, Schema.tokenization_create_request())
    post!("#{@base_path}/tokens", params, idempotentKey)
  end

  @tokenization_link_request [
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

  Options:\n#{NimbleOptions.docs(@tokenization_link_request)}
  """
  def link(link_req, idempotentKey \\ "") do
    {:ok, params} = NimbleOptions.validate(link_req, @tokenization_link_request)
    post!("#{@base_path}/tokens/link", params, idempotentKey)
  end

  @doc """
  Unlink a token. The token will be unlinked from the workspace. The token will not be deleted on chain nor the refId, only the link to the workspace will be removed.
  """
  def unlink(link_id) when is_binary(link_id) do
    delete!("#{@base_path}/tokens/link/#{link_id}")
  end

  @doc """
  Return a linked token, with its status and metadata.
  """
  def get_link(link_id) when is_binary(link_id) do
    get!("#{@base_path}/tokens/link/#{link_id}")
  end

  @get_deployable_address_request [
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

  Options:\n#{NimbleOptions.docs(@get_deployable_address_request)}
  """
  def get_deterministic_address(params, idempotentKey \\ "") do
    {:ok, params} = NimbleOptions.validate(params, @get_deployable_address_request)
    post!("#{@base_path}/tokens/deterministic_address", params, idempotentKey)
  end
end
