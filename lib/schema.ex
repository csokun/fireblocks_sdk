defmodule FireblocksSdk.Schema do
  def paged_vault_accounts_request_filters,
    do: [
      namePrefix: [type: :string],
      nameSuffix: [type: :string],
      minAmountThreshold: [type: :non_neg_integer],
      assetId: [type: :string],
      orderBy: [type: :string],
      limit: [type: :non_neg_integer],
      before: [type: :string],
      after: [type: :string]
    ]
end
