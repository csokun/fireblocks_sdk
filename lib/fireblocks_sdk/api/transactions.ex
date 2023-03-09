defmodule FireblocksSdk.Api.Transactions do
  alias FireblocksSdk.Schema

  import FireblocksSdk.Request

  @doc """
  List all transactions

  Options: \n#{NimbleOptions.docs(Schema.transaction_filter())}
  """
  def transactions(filter) do
    {:ok, params} = NimbleOptions.validate(filter, Schema.transaction_filter())

    query_string =
      params
      |> atom_to_upper([:status, :sourceType, :destType])
      |> atom_to_string([:orderBy])
      |> URI.encode_query()

    get("/v1/transactions?#{query_string}")
  end

  @doc """
  Creates a new transaction with the specified options

  Supported options:\n#{NimbleOptions.docs(Schema.create_transaction_request())}
  """
  def create_transaction(transaction, idempotent_key \\ "") do
    {:ok, options} = NimbleOptions.validate(transaction, Schema.create_transaction_request())

    params =
      options
      |> atom_to_upper([
        [:source, :type],
        [:source, :virtualType],
        [:destination, :type],
        [:destination, :virtualType],
        [:operation],
        [:feeLevel]
      ])
      |> Enum.into(%{})
      |> Jason.encode!()

    [_, data, _] = post("/v1/transactions", params, idempotent_key)
    data
  end

  def get_transaction_by_id(txId) when is_binary(txId) do
    [_, data, _] = get("/v1/transactions/#{txId}")
    data
  end
end
