defmodule FireblocksSdk.Models do
  @type asset_type_response :: %{
          id: String.t(),
          name: String.t(),
          type: String.t(),
          contractAddress: String.t(),
          nativeAsset: String.t()
        }

  @type balance_reward_info :: %{
          pendingRewards: String.t()
        }

  @type virtual_type :: %{}

  @type asset_response :: %{
          id: String.t(),
          total: String.t(),
          lockedAmount: String.t() | nil,
          available: String.t() | nil,
          pending: String.t() | nil,
          selfStakedCPU: String.t() | nil,
          selfStakedNetwork: String.t() | nil,
          pendingRefundCPU: String.t() | nil,
          pendingRefundNetwork: String.t() | nil,
          totalStakedCPU: String.t() | nil,
          totalStakedNetwork: String.t() | nil,
          rewardInfo: balance_reward_info(),
          blockHeight: String.t() | nil,
          blockHash: String.t(),
          allocatedBalances:
            %{
              allocatedId: String.t(),
              thirdPartyAccountId: String.t() | nil,
              # affiliation: "OFF_EXCHANGE" | "DEFAULT" | nil,
              # virtualType: "OFF_EXCHANGE" | "DEFAULT" | "OEC_FEE_BANK" | nil,
              total: String.t(),
              available: String.t(),
              pending: String.t() | nil,
              frozen: String.t() | nil,
              locked: String.t() | nil
            }
            | nil
        }

  @type vault_account_response :: %{
          id: String.t(),
          name: String.t(),
          hiddenOnUI: boolean | nil,
          assets: [asset_response()] | [],
          customerRefId: String.t() | nil,
          autoFuel: String.t() | nil
        }

  @type paged_vault_accounts_response :: %{
          accounts: [vault_account_response()],
          paging:
            %{
              before: String.t() | nil,
              after: String.t() | nil
            }
            | nil,
          previousUrl: String.t() | nil,
          nextUrl: String.t() | nil
        }
end
