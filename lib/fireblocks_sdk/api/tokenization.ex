defmodule FireblocksSdk.Api.Tokenization do
  alias FireblocksSdk.Schema

  import FireblocksSdk.Request

  @base_path "/v1/tokenization"

  @doc """
  Return all linked tokens (paginated)
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
end
