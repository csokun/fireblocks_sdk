defmodule FireblocksSdk.Api.Contract do
  import FireblocksSdk.Request

  @contract_endpoint "/v1/contracts"

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
end
