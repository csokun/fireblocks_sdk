defmodule FireblocksSdk.Api.Blockchain do
  alias FireblocksSdk.Schema
  import FireblocksSdk.Request

  @base_path "/v1/blockchains"

  @doc """
  Returns all blockchains supported by Fireblocks.

  Options:\n#{NimbleOptions.docs(Schema.blockchains_list())}
  """
  def list(opt \\ []) do
    {:ok, options} = NimbleOptions.validate(opt, Schema.blockchains_list())

    query_string =
      case options do
        [] -> ""
        _ -> "?" <> (options |> URI.encode_query())
      end

    get!("#{@base_path}#{query_string}")
  end

  @doc """
  The ID or legacyId of the blockchain
  """
  def get(id) when is_bitstring(id) do
    get!("#{@base_path}/#{id}")
  end
end
