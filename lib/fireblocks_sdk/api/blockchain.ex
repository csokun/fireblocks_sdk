defmodule FireblocksSdk.Api.Blockchain do
  import FireblocksSdk.Request

  @base_path "/v1/blockchains"

  @list_schema [
    protocol: [type: :string, doc: "The blockchain protocol"],
    deprecated: [type: :boolean, doc: "Is blockchain deprecated"],
    test: [type: :boolean, doc: "Is test blockchain"],
    ids: [type: {:list, :string}, doc: "A list of blockchain IDs (max 100)"],
    pageCursor: [type: :string, doc: "Page cursor to fetch"],
    pageSize: [type: :non_neg_integer, doc: "Items per page (max 500)"]
  ]

  @doc """
  Returns all blockchains supported by Fireblocks.

  Options:\n#{NimbleOptions.docs(@list_schema)}
  """
  def list(opt \\ []) do
    {:ok, options} = NimbleOptions.validate(opt, @list_schema)

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
