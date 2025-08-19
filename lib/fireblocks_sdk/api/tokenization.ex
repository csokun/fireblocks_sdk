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
end
