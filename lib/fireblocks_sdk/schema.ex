defmodule FireblocksSdk.Schema do
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
      feeLevel: [type: :string],
      gasFee: [type: :string]
    ]

  def transaction_set_confirmation_request(),
    do: [
      type: [type: {:in, [:txId, :txHash]}],
      id: [type: :string, doc: "Fireblocks transaction id or blockchain transaction hash"],
      numOfConfirmations: [type: :integer, default: 0]
    ]
end
