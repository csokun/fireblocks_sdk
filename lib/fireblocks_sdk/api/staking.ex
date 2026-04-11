defmodule FireblocksSdk.Api.Staking do
  import FireblocksSdk.Request

  @base_path "/v1/staking"

  @fee_level [:high, :medium, :low]

  @stake_schema [
    vaultAccountId: [
      type: :string,
      required: true,
      doc: "The source vault account to stake from"
    ],
    chainDescriptor: [type: :string, required: true],
    providerId: [
      type: :string,
      required: true,
      doc: "The unique identifier of the staking provider"
    ],
    stakeAmount: [type: :string, required: true, doc: "Amount of tokens to stake"],
    fee: [type: :string],
    feeLevel: [type: {:in, @fee_level}],
    txNote: [type: :string, required: false]
  ]

  @unstake_schema [
    id: [type: :string, required: true, doc: "id of position to unstake"],
    chainDescriptor: [type: :string, required: true],
    fee: [type: :string],
    feeLevel: [type: {:in, @fee_level}],
    txNote: [type: :string, required: false],
    amount: [
      type: :string,
      doc:
        "The number of tokens to unstake. This optional field is applicable only for liquid staking and allows for a partial unstake of the position. If not provided, the entire position will be unstaked by default."
    ]
  ]

  @withdraw_schema [
    id: [type: :string, required: true, doc: "id of position to withdraw"],
    chainDescriptor: [type: :string, required: true],
    fee: [type: :string],
    feeLevel: [type: {:in, @fee_level}],
    txNote: [type: :string, required: false]
  ]

  @claim_reawards_schema [
    id: [type: :string, required: true, doc: "id of position to claim rewards from"],
    chainDescriptor: [type: :string, required: true],
    fee: [type: :string],
    feeLevel: [type: {:in, @fee_level}],
    txNote: [type: :string, required: false]
  ]

  @split_schema [
    id: [type: :string, required: true, doc: "id of position to split"],
    chainDescriptor: [type: {:in, ["SOL", "SOL_TEST"]}, required: true],
    fee: [type: :string],
    feeLevel: [type: {:in, @fee_level}],
    txNote: [
      type: :string,
      required: false,
      doc: "The note to associate with the transactions."
    ],
    amount: [
      type: :string,
      required: true,
      doc: "Amount of tokens to be transferred to the new stake account."
    ]
  ]

  @merge_schema [
    chainDescriptor: [type: {:in, ["SOL", "SOL_TEST"]}, required: true],
    sourceId: [type: :string, required: true, doc: "Id of the source position to merge from"],
    destinationId: [
      type: :string,
      required: true,
      doc: "Id of the destination position to merge into"
    ],
    fee: [type: :string],
    feeLevel: [type: {:in, @fee_level}],
    txNote: [
      type: :string,
      required: false,
      doc: "The note to associate with the transactions."
    ]
  ]

  @doc """
  List staking supported chains
  """
  def supported_chains() do
    get!("#{@base_path}/chains")
  end

  @doc """
  Get chain-specific staking summary.

  Return chain-specific, staking-related information summary (e.g. epoch details, lockup durations, estimated rewards, etc.)

  Options:\n

    - `chain_descriptor`: The protocol identifier (e.g. "ETH"/"SOL"/"MATIC"/"STETH_ETH") to use
  """
  def get_chain_info(chain_descriptor) when is_binary(chain_descriptor) do
    get!("#{@base_path}/chains/#{chain_descriptor}/chainInfo")
  end

  @doc """
  List staking providers details
  """
  def get_providers() do
    get!("#{@base_path}/providers")
  end

  @doc """
  Get staking position details.

  Return detailed information on a staking position, including the staked amount, rewards, status and more.
  """
  def get_position(id) when is_binary(id) do
    get!("#{@base_path}/positions/#{id}")
  end

  @doc """
  List staking positions details

  ```
  FireblocksSdk.Api.Staking.positions("SOL")
  ```
  Options:\n

   - `chainDescriptor`: Use "ETH" / "SOL" / "MATIC" / "STETH_ETH" in order to obtain information related to the specific blockchain network or retrieve information about all chains that have data available by providing no argument.
  """
  def get_positions(chain_descriptor \\ "") do
    get!("#{@base_path}/positions?chainDescriptor=#{chain_descriptor}")
  end

  @doc """
  Get staking summary details.

  Return a summary of all vaults, categorized by their status (active, inactive), the total amounts staked and total rewards per-chain.
  """
  def get_positions_summary() do
    get!("#{@base_path}/positions/summary")
  end

  @doc """
  Get staking summary details by vault

  Return a summary for each vault, categorized by their status (active, inactive), the total amounts staked and total rewards per-chain.
  """
  def get_positions_summary_by_vault() do
    get!("#{@base_path}/positions/summary/vaults")
  end

  @doc """
  Approve staking terms of service.

  Approve the terms of service of the staking provider. This must be called before performing a staking action for the first time with this provider.
  """
  def accept_provider_term_of_service(provider_id, idempotentKey \\ "")
      when is_binary(provider_id) do
    post!("#{@base_path}/providers/#{provider_id}/approveTermsOfService", "", idempotentKey)
  end

  @doc """
  Init Stake operation - Perform a chain-specific Stake.

  ```
  FireblocksSdk.Api.Staking.stake([
    vaultAccountId: "22",
    providerId: "kiln",
    chainDescriptor: "SOL",
    stakeAmount: "100",
    txNote: "stake request id CcaHc2L43ZWjwCHART3oZoJvHLAe9hzT2DJNUpBzoTN1 of 100 SOL created on 02.04.23",
    feeLevel: :medium
  ])
  ```

  Options:\n#{NimbleOptions.docs(@stake_schema)}
  """
  def stake(staking, idempotentKey \\ "") do
    {:ok, options} = NimbleOptions.validate(staking, @stake_schema)

    chain_descriptor = options[:chainDescriptor]

    params =
      options
      |> Keyword.delete(:chainDescriptor)
      |> Enum.into(%{})
      |> Jason.encode!()

    post!(
      "#{@base_path}/chains/#{chain_descriptor}/stake",
      params,
      idempotentKey
    )
  end

  @doc """
  Execute an unstake operation.

  ```
  FireblocksSdk.Api.Staking.unstake([
    id: "b70701f4-d7b1-4795-a8ee-b09cdb5b850d",
    chainDescriptor: "SOL",
    txNote: "unstake request id b70701f4-d7b1-4795-a8ee-b09cdb5b850d #SOL",
    feeLevel: :medium
  ])
  ```

  Options:\n#{NimbleOptions.docs(@unstake_schema)}
  """
  def unstake(unstaking, idempotentKey \\ "") do
    {:ok, options} = NimbleOptions.validate(unstaking, @unstake_schema)

    chain_descriptor = options[:chainDescriptor]

    params =
      options
      |> Keyword.delete(:chainDescriptor)
      |> Enum.into(%{})
      |> Jason.encode!()

    post!(
      "#{@base_path}/chains/#{chain_descriptor}/unstake",
      params,
      idempotentKey
    )
  end

  @doc """
  Execute a Withdraw operation.

  ```
  FireblocksSdk.Api.Staking.withdraw([
    id: "b70701f4-d7b1-4795-a8ee-b09cdb5b850d",
    chainDescriptor: "SOL",
    txNote: "unstake request id b70701f4-d7b1-4795-a8ee-b09cdb5b850d #SOL",
    feeLevel: :medium
  ])
  ```

  Options:\n#{NimbleOptions.docs(@withdraw_schema)}
  """
  def withdraw(withdrawal, idempotentKey \\ "") do
    {:ok, options} = NimbleOptions.validate(withdrawal, @withdraw_schema)

    chain_descriptor = options[:chainDescriptor]

    params =
      options
      |> Keyword.delete(:chainDescriptor)
      |> Enum.into(%{})
      |> Jason.encode!()

    post!(
      "#{@base_path}/chains/#{chain_descriptor}/withdraw",
      params,
      idempotentKey
    )
  end

  @doc """
  Execute a Claim Rewards operation.

  ```
  FireblocksSdk.Api.Staking.claim_reawards([
    id: "b70701f4-d7b1-4795-a8ee-b09cdb5b850d",
    chainDescriptor: "SOL",
    txNote: "claim rewards request id b70701f4-d7b1-4795-a8ee-b09cdb5b850d",
    feeLevel: :medium
  ])
  ```

  Options:\n#{NimbleOptions.docs(@claim_reawards_schema)}
  """
  def claim_reawards(claim_request, idempotentKey \\ "") do
    {:ok, options} = NimbleOptions.validate(claim_request, @claim_reawards_schema)

    chain_descriptor = options[:chainDescriptor]

    params =
      options
      |> Keyword.delete(:chainDescriptor)
      |> Enum.into(%{})
      |> Jason.encode!()

    post!(
      "#{@base_path}/chains/#{chain_descriptor}/claim_rewards",
      params,
      idempotentKey
    )
  end

  @doc """
  Execute a Split operation on SOL/SOL_TEST stake account.

  ```
  FireblocksSdk.Api.Staking.split([
    id: "b70701f4-d7b1-4795-a8ee-b09cdb5b850d",
    chainDescriptor: "SOL",
    amount: "20",
    txNote: "split 20 SOL out of 100 SOL, created on 02.04.23",
    feeLevel: :medium
  ])
  ```

  Options:\n#{NimbleOptions.docs(@split_schema)}
  """
  def split(split_request, idempotentKey \\ "") do
    {:ok, options} = NimbleOptions.validate(split_request, @split_schema)

    chain_descriptor = options[:chainDescriptor]

    params =
      options
      |> Keyword.delete(:chainDescriptor)
      |> Enum.into(%{})
      |> Jason.encode!()

    post!(
      "#{@base_path}/chains/#{chain_descriptor}/split",
      params,
      idempotentKey
    )
  end

  @doc """
  Perform a Solana Merge of two active stake accounts into one.

  ```
  FireblocksSdk.Api.Staking.merge([
    chainDescriptor: "SOL",
    sourceId: "b70701f4-d7b1-4795-a8ee-b09cdb5b850f",
    destinationId: "f3432f4-34d1-43495-a8ee-jfdjnfj34i3",
    feeLevel: :medium
  ])
  ```

  Options:\n#{NimbleOptions.docs(@merge_schema)}
  """
  def merge(merge_request, idempotentKey \\ "") do
    {:ok, options} = NimbleOptions.validate(merge_request, @merge_schema)

    chain_descriptor = options[:chainDescriptor]

    params =
      options
      |> Keyword.delete(:chainDescriptor)
      |> Enum.into(%{})
      |> Jason.encode!()

    post!(
      "#{@base_path}/chains/#{chain_descriptor}/merge",
      params,
      idempotentKey
    )
  end

  @consolidate_schema [
    chainDescriptor: [
      type: {:in, ["ETH", "ETH_TEST6", "ETH_TEST_HOODI"]},
      required: true,
      doc: "Protocol identifier. Supported values: `ETH`, `ETH_TEST6`, `ETH_TEST_HOODI`"
    ],
    sourceId: [
      type: :string,
      required: true,
      doc: "Id of the source position to consolidate from"
    ],
    destinationId: [
      type: :string,
      required: true,
      doc: "Id of the destination position to consolidate into"
    ],
    fee: [
      type: :string,
      doc: "Fee for the transaction. Only one of `fee`/`feeLevel` is required."
    ],
    feeLevel: [type: {:in, @fee_level}],
    txNote: [type: :string, doc: "The note to associate with the consolidation transaction."]
  ]

  @doc """
  Consolidate ETH staking positions (validator consolidation).

  Merges a source ETH staking position into a destination position on the beacon chain.

  ```
  FireblocksSdk.Api.Staking.consolidate([
    chainDescriptor: "ETH",
    sourceId: "b70701f4-d7b1-4795-a8ee-b09cdb5b850d",
    destinationId: "f3432f4-34d1-43495-a8ee-jfdjnfj34i3",
    feeLevel: :medium
  ])
  ```

  Options:\n#{NimbleOptions.docs(@consolidate_schema)}
  """
  def consolidate(consolidate_request, idempotentKey \\ "") do
    {:ok, options} = NimbleOptions.validate(consolidate_request, @consolidate_schema)

    chain_descriptor = options[:chainDescriptor]

    params =
      options
      |> Keyword.delete(:chainDescriptor)
      |> atom_to_upper([:feeLevel])
      |> Enum.into(%{})
      |> Jason.encode!()

    post!(
      "#{@base_path}/chains/#{chain_descriptor}/consolidate",
      params,
      idempotentKey
    )
  end

  @get_positions_paginated_schema [
    pageSize: [
      type: :integer,
      default: 10,
      doc:
        "Number of results per page (min: 1, max: 100). Returns a paginated `{data, next}` object."
    ],
    chainDescriptor: [
      type: :string,
      doc:
        "Protocol identifier to filter positions (e.g. `ETH`, `SOL`, `ATOM_COS`). If omitted, positions across all supported chains are returned."
    ],
    vaultAccountId: [
      type: :string,
      doc:
        "Filter positions by Fireblocks vault account ID. If omitted, positions across all vault accounts are returned."
    ],
    pageCursor: [
      type: :string,
      doc: "Cursor for the next page of results. Use the `next` value from the previous response."
    ],
    order: [
      type: {:in, ["ASC", "DESC"]},
      default: "DESC",
      doc: "Sort order: `ASC` or `DESC` (default: `DESC`)"
    ]
  ]

  @doc """
  List staking positions (paginated).

  Returns a paginated list of staking positions. Use `pageCursor` from the response's `next` field
  to fetch subsequent pages.

  ```
  FireblocksSdk.Api.Staking.get_positions_paginated([
    pageSize: 20,
    chainDescriptor: "ETH",
    order: "DESC"
  ])
  ```

  Options:\n#{NimbleOptions.docs(@get_positions_paginated_schema)}
  """
  def get_positions_paginated(options \\ []) do
    {:ok, params} = NimbleOptions.validate(options, @get_positions_paginated_schema)
    query_string = params |> URI.encode_query()
    get!("#{@base_path}/positions_paginated?#{query_string}")
  end
end
