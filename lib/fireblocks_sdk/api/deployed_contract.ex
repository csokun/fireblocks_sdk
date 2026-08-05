defmodule FireblocksSdk.Api.DeployedContract do
  import FireblocksSdk.Request

  @base_path "/v1/tokenization/contracts"

  @list_deployed_contracts [
    pageCursor: [type: :string],
    pageSize: [type: :non_neg_integer, default: 10],
    contractAddress: [type: :string],
    baseAssetId: [type: :string],
    contractTemplateId: [type: :string]
  ]

  @doc """
  List deployed contracts data

  ```
    FireblocksSdk.Api.DeployedContract.list([
      contractAddress: "0x56Ba8B58B7d1f6d384A1C4dD553F39ebc8741B8e",
      baseAssetId: "ETH"
    ])
  ```

  Return a filtered lean representation of the deployed contracts data on all blockchains (paginated)

  Options:\n#{NimbleOptions.docs(@list_deployed_contracts)}
  """
  def list(filter \\ []) do
    {:ok, params} = NimbleOptions.validate(filter, @list_deployed_contracts)
    query = params |> URI.encode_query()
    get!("#{@base_path}?#{query}")
  end

  @doc """
  Return deployed contract data by id
  """
  def get(id), do: get!("#{@base_path}/#{id}")

  @contract_data [
    contractAddress: [type: :string, required: true],
    assetId: [type: :string, required: true]
  ]
  @doc """
  Return deployed contract data by blockchain native asset id and contract address

  Options:\n#{NimbleOptions.docs(@contract_data)}
  """
  def get_data(filter) do
    {:ok, params} = NimbleOptions.validate(filter, @contract_data)
    get!("#{@base_path}/#{params[:assetId]}/#{params[:contractAddress]}")
  end

  @fetch_abi_schema [
    baseAssetId: [type: :string, required: true],
    contractAddress: [type: :string, required: true]
  ]
  @doc """
  Fetch ABI for a deployed contract

  Options:\n#{NimbleOptions.docs(@fetch_abi_schema)}
  """
  def fetch_abi(filter, idempotentKey \\ "") do
    {:ok, params} = NimbleOptions.validate(filter, @fetch_abi_schema)
    data = params |> Enum.into(%{}) |> Jason.encode!()
    post!("#{@base_path}/fetch_abi", data, idempotentKey)
  end

  # Parameter Schema
  @parameter_schema [
    name: [
      type: :string,
      required: true,
      doc: "Parameter name"
    ],
    description: [
      type: :string,
      doc: "Parameter description"
    ],
    internalType: [
      type: :string,
      doc: "Internal Solidity type"
    ],
    type: [
      type: :string,
      required: true,
      doc: "Parameter type"
    ],
    components: [
      type: {:list, :map},
      doc: "Tuple components if applicable"
    ]
  ]

  # AbiFunction Schema
  @abi_function_schema [
    name: [
      type: :string,
      doc: "The name of the contract function as it appears in the ABI"
    ],
    stateMutability: [
      type: {:in, ["pure", "view", "nonpayable", "payable"]},
      doc: "The state mutability of the contract function"
    ],
    type: [
      type: {:in, ["constructor", "function", "error", "event", "receive", "fallback"]},
      required: true,
      doc: "The type of the function"
    ],
    inputs: [
      type: {:list, {:keyword_list, @parameter_schema}},
      doc: "The parameters that this function/constructor possesses"
    ],
    outputs: [
      type: {:list, {:keyword_list, @parameter_schema}},
      doc: "The parameters that this 'read' function returns"
    ],
    description: [
      type: :string,
      doc: "The documentation of this function (if has any)"
    ]
  ]

  @upload_abi_schema [
    contractAddress: [
      type: :string,
      required: true,
      doc: "Address of the contract"
    ],
    baseAssetId: [
      type: :string,
      required: true,
      doc: "Base asset identifier"
    ],
    abi: [
      type: {:list, {:keyword_list, @abi_function_schema}},
      required: true,
      doc: "The ABI of the contract, consisting of ABI function definitions"
    ],
    name: [
      type: :string,
      required: false,
      doc: "Optional name field"
    ]
  ]
  @doc """
  Upload ABI for a deployed contract

  Options:\n#{NimbleOptions.docs(@upload_abi_schema)}
  """
  def upload_abi(filter, idempotentKey \\ "") do
    {:ok, params} = NimbleOptions.validate(filter, @upload_abi_schema)
    data = params |> Enum.into(%{}) |> Jason.encode!()
    post!("#{@base_path}/abi", data, idempotentKey)
  end
end
