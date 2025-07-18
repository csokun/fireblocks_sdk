defmodule FireblocksSdk.Schema do
  @moduledoc false

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

  @transaction_order_by [:createdAt, :lastUpdated]

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

  @operation_type [
    :transfer,
    :mint,
    :burn,
    :supply_to_compound,
    :redeem_from_compound,
    :raw,
    :contract_call,
    :typed_message
  ]

  @fee_level [:high, :medium, :low]

  @virtual_type [:off_exchange, :default, :oec_fee_bank]

  def paged_vault_accounts_request_filters(),
    do: [
      namePrefix: [type: :string],
      nameSuffix: [type: :string],
      minAmountThreshold: [type: :non_neg_integer],
      assetId: [type: :string],
      orderBy: [type: {:in, [:asc, :desc]}],
      limit: [type: :non_neg_integer],
      before: [type: :string],
      after: [type: :string]
    ]

  def vault_balance_filter(),
    do: [
      accountNamePrefix: [type: :string],
      accountNameSuffic: [type: :string]
    ]

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
      status: [type: {:in, @transaction_status}],
      orderBy: [type: {:in, @transaction_order_by}],
      limit: [type: :integer],
      txHash: [type: :string],
      assets: [type: :string],
      sourceType: [type: {:in, @peer_type}],
      destType: [type: {:in, @peer_type}],
      sourceId: [type: :string],
      destId: [type: :string]
    ]

  def create_transaction_request(),
    do: [
      assetId: [type: :string],
      source: [
        type: :map,
        keys: [
          type: [type: {:in, @peer_type}],
          id: [type: :string],
          virtualId: [type: :string],
          virtualType: [type: {:in, @virtual_type}],
          address: [type: :string]
        ]
      ],
      destination: [
        type: :map,
        keys: [
          type: [type: {:in, @peer_type}],
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
      amount: [type: :string],
      operation: [
        type: {:in, @operation_type}
      ],
      fee: [type: :string],
      feeLevel: [type: {:in, @fee_level}],
      failOnLowFee: [type: :boolean],
      maxFee: [type: :string],
      priorityFee: [type: :string],
      gasPrice: [type: :string],
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
      replaceTxByHash: [type: :string],
      externalTxId: [type: :string],
      treatAsGrossAmount: [type: :boolean],
      forceSweep: [type: :boolean],
      feePayerInfo: [
        type: :map,
        keys: [
          feePayerAccountId: [type: :string]
        ]
      ]
    ]

  def transaction_drop_request(),
    do: [
      txId: [type: :string, required: true],
      feeLevel: [type: {:in, [:high, :medium, :low]}],
      gasFee: [type: :string]
    ]

  def transaction_set_confirmation_request(),
    do: [
      type: [type: {:in, [:txId, :txHash]}],
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
      vaultAccountId: [type: :string, required: true],
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
end
