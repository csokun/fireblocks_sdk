defmodule FireblocksSdk.Schema do
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

  def transaction_request(),
    do: [
      assetId: [type: :string],
      # source: [type: :TransferPeerPath],
      # destination: [type: :DestinationTransferPeerPath],
      amount: [type: :string],
      operation: [
        type:
          {:in,
           [
             :transfer,
             :mint,
             :burn,
             :supply_to_compound,
             :redeem_from_compound,
             :raw,
             :contract_call,
             :typed_message
           ]}
      ],
      fee: [type: :string],
      feeLevel: [type: {:in, [:high, :medium, :low]}],
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
      # destinations: [type: :TransactionDestination],
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
end
