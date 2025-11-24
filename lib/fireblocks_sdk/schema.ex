defmodule FireblocksSdk.Schema do
  @moduledoc false

  @pagination [
    limit: [
      type: :non_neg_integer,
      default: 200,
      doc:
        "The maximum number of asset wallets in a single response. The default is 200 and the maximum is 1000."
    ],
    before: [
      type: :string,
      doc:
        "Fetches the next paginated response before this element. This element is a cursor and is returned at the response of the previous page."
    ],
    after: [
      type: :string,
      doc:
        "Fetches the next paginated response after this element. This element is a cursor and is returned at the response of the previous page."
    ]
  ]

  @trading_account_type [
    :coin_futures,
    :coin_margined_swap,
    :exchange,
    :funding,
    :fundable,
    :futures,
    :futures_cross,
    :margin,
    :margin_cross,
    :options,
    :spot,
    :usdt_margined_swap_cross,
    :usdt_futures,
    :unified
  ]

  @transaction_status [
    :submitted,
    :queued,
    :pending_signature,
    :pending_authorization,
    :pending_3rd_party_manual_approval,
    :pending_3rd_party,
    :broadcasting,
    :confirming,
    :completed,
    :pending_aml_screening,
    :partially_completed,
    :cancelling,
    :cancelled,
    :rejected,
    :failed,
    :timeout,
    :blocked
  ]

  @peer_type [
    :vault_account,
    :exchange_account,
    :internal_wallet,
    :external_wallet,
    :unknown,
    :network_connection,
    :fiat_account,
    :compound,
    :one_time_address,
    :oec_partner
  ]

  @peer [
    type: {:in, @peer_type},
    doc:
      "one of `:vault_account`, `:exchange_account`, `:internal_wallet`, `:external_wallet`, `:unknown`, `:network_connection`, `:fiat_account`, `:compound`, `:one_time_address`, `:oec_partner`"
  ]

  @fee_level [:high, :medium, :low]

  @virtual_type [:off_exchange, :default, :oec_fee_bank]

  def vault_listing_request(),
    do:
      [
        namePrefix: [type: :string],
        nameSuffix: [type: :string],
        minAmountThreshold: [type: :non_neg_integer],
        assetId: [type: :string],
        orderBy: [type: {:in, [:asc, :desc]}, doc: "order by `:asc` or `:desc`"]
      ] ++ @pagination

  def vault_balance_filter(),
    do: [
      accountNamePrefix: [type: :string],
      accountNameSuffic: [type: :string]
    ]

  def vault_asset_addresses_request(),
    do:
      [
        vaultAccountId: [type: :string, required: true],
        assetId: [type: :string, required: true]
      ] ++ @pagination

  def vault_asset_wallets(),
    do:
      [
        totalAmountLargerThan: [
          type: {:or, [:non_neg_integer, :float]},
          doc:
            "When specified, only asset wallets with total balance larger than this amount are returned."
        ],
        assetId: [
          type: :string,
          doc:
            "When specified, only asset wallets cross vault accounts that have this asset ID are returned."
        ],
        orderBy: [type: {:in, [:asc, :desc]}, doc: "order by `:asc` or `:desc`"]
      ] ++ @pagination

  def transaction_filter(),
    do: [
      before: [
        type: :string,
        doc:
          "Unix timestamp in milliseconds. Returns only transactions created before the specified date"
      ],
      after: [
        type: :string,
        doc:
          "Unix timestamp in milliseconds. Returns only transactions created after the specified date"
      ],
      status: [
        type: {:in, @transaction_status},
        doc:
          "available values `:submitted`, `:queued`, `:pending_signature`, `:pending_authorization`, `:pending_3rd_party_manual_approval`, `:pending_3rd_party`, `:broadcasting`, `:confirming`, `:completed`, `:pending_aml_screening`, `:partially_completed`, `:cancelling`, `:cancelled`, `:rejected`, `:failed`, `:timeout`, `:blocked`"
      ],
      orderBy: [
        type: {:in, [:createdAt, :lastUpdated]},
        doc: "available values `:createdAt`, `:lastUpdated`"
      ],
      sort: [type: {:in, [:asc, :desc]}, doc: "one of `:asc` or `:desc`"],
      limit: [
        type: :integer,
        doc:
          "Limits the number of results. If not provided, a limit of 200 will be used. The maximum allowed limit is 500"
      ],
      txHash: [type: :string, doc: "Returns only results with a specified txHash"],
      assets: [type: :string, doc: "A list of assets to filter by, seperated by commas"],
      sourceType: @peer,
      destType: @peer,
      sourceId: [type: :string],
      destId: [type: :string, doc: "The destination ID of the transaction"],
      sourceWalletId: [
        type: :string,
        doc: "Returns only results where the source is a specific end user wallet"
      ],
      destWalletId: [
        type: :string,
        doc: "Returns only results where the destination is a specific end user wallet"
      ],
      next: [type: :string, doc: "Retrieve the next page of results"],
      prev: [type: :string, doc: "Retrieve the previous page of results"]
    ]

  def create_transaction_request(),
    do: [
      assetId: [type: :string],
      source: [
        type: :map,
        keys: [
          type: @peer,
          id: [type: :string],
          virtualId: [type: :string],
          virtualType: [type: {:in, @virtual_type}],
          address: [type: :string]
        ]
      ],
      destination: [
        type: :map,
        keys: [
          type: @peer,
          id: [type: :string],
          virtualId: [type: :string],
          virtualType: [type: {:in, @virtual_type}],
          oneTimeAddress: [
            type: :map,
            keys: [
              address: [type: :string],
              tag: [type: :string]
            ]
          ]
        ]
      ],
      amount: [
        type: :string,
        doc: "For **TRANSFER** operations, the requested amount to transfer, in the asset’s unit."
      ],
      operation: [
        type:
          {:in,
           [
             :transfer,
             :mint,
             :burn,
             :contract_call,
             :program_call,
             :typed_message,
             :raw,
             :approve,
             :enable_asset
           ]},
        doc:
          "available value `:transfer`, `:mint`, `:burn`, `:contract_call`, `:program_call`, `:raw`, `:typed_message`, `:approve`, `:enable_asset`"
      ],
      fee: [type: :string],
      feeLevel: [
        type: {:in, @fee_level},
        doc:
          "For UTXO or EVM-based blockchains only. Defines the blockchain fee level which will be payed for the transaction. Alternatively, specific fee estimation parameters exist below."
      ],
      failOnLowFee: [type: :boolean],
      maxFee: [type: :string],
      priorityFee: [type: :string],
      gasPrice: [
        type: :string,
        doc: """
        For non-EIP-1559, EVM-based transactions. Price per gas unit (in Ethereum this is specified in Gwei).

        **Note:** Only two of the three arguments can be specified in a single transaction: gasLimit, gasPrice and networkFee. Fireblocks recommends using a numeric string for accurate precision. Although a number input exists, it is deprecated.
        """
      ],
      gasLimit: [type: :string],
      note: [type: :string],
      cpuStaking: [type: :integer],
      networkStaking: [type: :integer],
      autoStaking: [type: :boolean],
      customerRefId: [type: :string],
      extraParameters: [type: :map],
      destinations: [
        type: :map,
        keys: [
          amount: [type: :string],
          destination: [
            type: :map,
            keys: [
              type: [type: {:in, @peer_type}],
              id: [type: :string],
              oneTimeAddress: [
                type: :map,
                keys: [
                  address: [type: :string],
                  tag: [type: :string]
                ]
              ]
            ]
          ]
        ]
      ],
      replaceTxByHash: [
        type: :string,
        doc:
          "For EVM-based blockchains only. In case a transaction is stuck, specify the hash of the stuck transaction to replace it by this transaction with a higher fee, or to replace it with this transaction with a zero fee and drop it from the blockchain."
      ],
      externalTxId: [type: :string],
      treatAsGrossAmount: [
        type: :boolean,
        doc: """
        When set to true, the fee will be deducted from the requested amount.

        **Note:** This parameter can only be considered if a transaction’s asset is a base asset, such as ETH or MATIC. If the asset can’t be used for transaction fees, like USDC, this parameter is ignored and the fee is deducted from the relevant base asset wallet in the source account.
        """
      ],
      forceSweep: [
        type: :boolean,
        doc: """
        For Polkadot, Kusama and Westend transactions only. When set to true, Fireblocks will empty the asset wallet.

        **Note:** If set to true when the source account is exactly 1 DOT, the transaction will fail. Any amount more or less than 1 DOT succeeds. This is a Polkadot blockchain limitation.
        """
      ],
      feePayerInfo: [
        type: :map,
        keys: [
          feePayerAccountId: [type: :string]
        ]
      ],
      travelRuleMessageId: [type: :string],
      useGasless: [type: :boolean]
    ]

  def transaction_drop_request(),
    do: [
      txId: [type: :string, required: true],
      feeLevel: [type: {:in, [:high, :medium, :low]}],
      gasFee: [type: :string]
    ]

  def transaction_set_confirmation_request(),
    do: [
      type: [type: {:in, [:txId, :txHash]}, doc: "available value `:txId`, `:txHash`"],
      id: [type: :string, doc: "Fireblocks transaction id or blockchain transaction hash"],
      numOfConfirmations: [type: :integer, default: 0]
    ]

  def gas_station_settings_request(),
    do: [
      gasThreshold: [type: :string, required: true],
      gasCap: [type: :string, required: true],
      maxGasPrice: [type: :string],
      assetId: [type: :string]
    ]

  def vault_create_request(),
    do: [
      name: [type: :string, required: true],
      hiddenOnUI: [type: :boolean, default: false],
      customerRefId: [type: :string],
      autoFuel: [type: :boolean, default: true]
    ]

  def vault_account_filter(),
    do: [
      namePrefix: [type: :string],
      nameSuffix: [type: :string],
      minAmountThreshold: [type: :non_neg_integer],
      assetId: [type: :string],
      maxBip44AddressIndexUsed: [type: :non_neg_integer],
      maxBip44ChangeAddressIndexUsed: [type: :non_neg_integer]
    ]

  def vault_set_customer_ref_id_request(),
    do: [
      vaultId: [type: :string, required: true],
      assetId: [type: :string],
      addressId: [type: :string],
      customerRefId: [type: :string, required: true]
    ]

  def vault_auto_fuel_request(),
    do: [
      vaultId: [type: :string, required: true],
      autoFuel: [type: :boolean, required: true, default: true]
    ]

  def vault_create_wallet_request(),
    do: [
      vaultId: [type: :string, required: true],
      assetId: [type: :string, required: true],
      eosAccountName: [type: :string]
    ]

  def vault_address_description_request(),
    do: [
      vaultId: [type: :string, required: true],
      assetId: [type: :string, required: true],
      addressId: [type: :string, required: true],
      description: [type: :string, default: ""]
    ]

  def vault_public_key_info_filter(),
    do: [
      vaultId: [type: :string],
      assetId: [type: :string],
      addressId: [type: :string],
      change: [type: :string],
      derivationPath: [type: :string, required: true],
      algorithm: [type: :string, required: true],
      compressed: [type: :boolean]
    ]

  def exchange_accounts_request(),
    do: [
      before: [type: :string],
      after: [type: :string],
      limit: [type: :non_neg_integer, default: 3]
    ]

  def exchange_transfer_request(),
    do: [
      exchangeId: [type: :string, required: true],
      asset: [type: :string, required: true],
      amount: [type: :string, required: true],
      sourceType: [type: {:in, @trading_account_type}, required: true],
      destType: [type: {:in, @trading_account_type}, required: true]
    ]

  def exchange_convert_request(),
    do: [
      exchangeId: [type: :string, required: true],
      amount: [type: :string, required: true],
      srcAsset: [type: :string, required: true],
      destAsset: [type: :string, required: true]
    ]

  def wallet_create_request(),
    do: [
      name: [type: :string, required: true],
      customerRefId: [type: :string]
    ]

  def wallet_set_customer_ref_id_request(),
    do: [
      walletId: [type: :string, required: true],
      customerRefId: [type: :string, required: true]
    ]

  def wallet_add_asset_request(),
    do: [
      walletId: [type: :string, required: true],
      assetId: [type: :string, required: true],
      address: [type: :string],
      tag: [type: :string]
    ]

  def create_api_user_request(),
    do: [
      role: [type: :string, required: true],
      name: [type: :string, required: true],
      csrPem: [type: :string, doc: "only for user with signing capability"],
      coSignerSetupType: [type: :string],
      coSignerSetupIsFirstUser: [type: :boolean, default: false]
    ]

  def create_console_user_request(),
    do: [
      firstName: [type: :string, required: true],
      lastName: [type: :string, required: true],
      role: [type: :string, required: true],
      email: [type: :string, required: true]
    ]

  def tokenization_list_request(),
    do: [
      pageCursor: [type: :string],
      pageSize: [type: :non_neg_integer, default: 10],
      status: [type: :string, default: "COMPLETED"]
    ]

  def tokenization_create_request(),
    do: [
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

  def blockchains_list(),
    do: [
      protocol: [type: :string, doc: "The blockchain protocol"],
      deprecated: [type: :boolean, doc: "Is blockchain deprecated"],
      test: [type: :boolean, doc: "Is test blockchain"],
      ids: [type: {:list, :string}, doc: "A list of blockchain IDs (max 100)"],
      pageCursor: [type: :string, doc: "Page cursor to fetch"],
      pageSize: [type: :non_neg_integer, doc: "Items per page (max 500)"]
    ]

  def staking_stake_request(),
    do: [
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

  def staking_unstake_request(),
    do: [
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

  def staking_withdraw_request(),
    do: [
      id: [type: :string, required: true, doc: "id of position to unstake"],
      chainDescriptor: [type: :string, required: true],
      fee: [type: :string],
      feeLevel: [type: {:in, @fee_level}],
      txNote: [type: :string, required: false]
    ]

  def staking_claim_rewards_request(),
    do: [
      id: [type: :string, required: true, doc: "id of position to unstake"],
      chainDescriptor: [type: :string, required: true],
      fee: [type: :string],
      feeLevel: [type: {:in, @fee_level}],
      txNote: [type: :string, required: false]
    ]

  def staking_split_request(),
    do: [
      id: [type: :string, required: true, doc: "id of position to unstake"],
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

  def staking_merge_request(),
    do: [
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
end
