defmodule FireblocksSdk.Api.Nft do
  @moduledoc """
  Fireblocks NFTs API.

  Covers all endpoints under the `NFTs` tag (`/v1/nfts`), split across two
  resource families:

  * **Token data** (`/v1/nfts/tokens`) — retrieve and refresh NFT metadata.
  * **Ownership** (`/v1/nfts/ownership`) — list, filter, and update the status
    or spam classification of NFTs held across vault accounts or
    Non-Custodial Wallets (NCW).

  All paginated `GET` endpoints use cursor-based pagination via `pageCursor`
  and return a `paging.next` cursor for the following page.
  """

  import FireblocksSdk.Request

  @base_path "/v1/nfts"

  # ---------------------------------------------------------------------------
  # Shared pagination fields reused across query-param schemas
  # ---------------------------------------------------------------------------

  @pagination [
    pageCursor: [
      type: :string,
      doc: "Page cursor returned from a previous response's `paging.next` field"
    ],
    pageSize: [
      type: :non_neg_integer,
      doc: "Number of items per page (min: 1, max: 100)"
    ]
  ]

  # ===========================================================================
  # Token Data  —  /v1/nfts/tokens
  # ===========================================================================

  @doc """
  Returns the token data for a single NFT by its Fireblocks NFT asset ID.

  - `id`: Fireblocks NFT asset ID, e.g. `"NFT-abcdefabcdefabcdefabcdefabcdefabcdefabcd"`.
  """
  @spec get_nft(String.t()) :: map()
  def get_nft(id) when is_binary(id) do
    get!("#{@base_path}/tokens/#{id}")
  end

  @get_nfts_schema [
                     ids: [
                       type: :string,
                       required: true,
                       doc:
                         "Comma-separated list of Fireblocks NFT asset IDs to retrieve (max 100)"
                     ],
                     sort: [
                       type: :string,
                       doc:
                         "Comma-separated sort field(s). Allowed values: `collection.name`, `name`, `blockchainDescriptor`"
                     ],
                     order: [
                       type: {:in, ["ASC", "DESC"]},
                       doc: "Sort direction — `\"ASC\"` (default) or `\"DESC\"`"
                     ]
                   ] ++ @pagination

  @doc """
  Returns token data for a batch of NFTs identified by their Fireblocks asset IDs.

  The required `ids` option is a comma-separated string of up to 100 NFT asset IDs.

  Options:\n#{NimbleOptions.docs(@get_nfts_schema)}
  """
  @spec get_nfts(keyword()) :: map()
  def get_nfts(params) do
    {:ok, opts} = NimbleOptions.validate(params, @get_nfts_schema)
    query_string = URI.encode_query(opts)
    get!("#{@base_path}/tokens?#{query_string}")
  end

  @doc """
  Triggers a refresh of the metadata for a single NFT.

  Fireblocks will re-fetch the token's `metadataURI` and update cached values.
  Returns `202 Accepted` — the refresh happens asynchronously.

  - `id`: Fireblocks NFT asset ID.
  - `idempotency_key`: Optional `X-Idempotency-Key` header value.
  """
  @spec refresh_nft_metadata(String.t(), String.t()) :: any()
  def refresh_nft_metadata(id, idempotency_key \\ "") when is_binary(id) do
    put!("#{@base_path}/tokens/#{id}", "", idempotency_key)
  end

  # ===========================================================================
  # Ownership  —  /v1/nfts/ownership
  # ===========================================================================

  @update_ownership_tokens_schema [
    blockchainDescriptor: [
      type: :string,
      required: true,
      doc: """
      Blockchain to refresh. Supported values: `ETH`, `ETH_TEST5`, `ETH_TEST6`,
      `POLYGON`, `POLYGON_TEST_MUMBAI`, `AMOY_POLYGON_TEST`, `BASECHAIN_ETH`,
      `BASECHAIN_ETH_TEST5`, `ETHERLINK`, `ETHERLINK_TEST`, `MANTLE`,
      `MANTLE_TEST`, `GUN_GUNZILLA`, `GUN_GUNZILLA_TEST`, `ETH_SONEIUM`,
      `SONEIUM_MINATO_TEST`, `IOTX_IOTEX`, `KLAY_KAIA`, `KLAY_KAIA_TEST`,
      `APECHAIN`, `APECHAIN_TEST`, `ROBINHOOD_CHAIN_TESTNET_TEST`
      """
    ],
    vaultAccountId: [
      type: :string,
      required: true,
      doc: "Vault account ID whose token balances should be refreshed"
    ]
  ]

  @doc """
  Refreshes all token balances for a given vault account on the specified blockchain.

  Triggers an asynchronous update; returns `202 Accepted`.

  - `idempotency_key`: Optional `X-Idempotency-Key` header value.

  Options:\n#{NimbleOptions.docs(@update_ownership_tokens_schema)}
  """
  @spec update_ownership_tokens(keyword(), String.t()) :: any()
  def update_ownership_tokens(params, idempotency_key \\ "") do
    {:ok, opts} = NimbleOptions.validate(params, @update_ownership_tokens_schema)
    query_string = URI.encode_query(opts)
    put!("#{@base_path}/ownership/tokens?#{query_string}", "", idempotency_key)
  end

  @get_ownership_tokens_schema [
                                 blockchainDescriptor: [
                                   type: :string,
                                   doc: """
                                   Filter by blockchain. Supported values: `ETH`, `ETH_TEST3`,
                                   `ETH_TEST5`, `ETH_TEST6`, `POLYGON`, `POLYGON_TEST_MUMBAI`,
                                   `AMOY_POLYGON_TEST`, `XTZ`, `XTZ_TEST`, `BASECHAIN_ETH`,
                                   `BASECHAIN_ETH_TEST3`, `BASECHAIN_ETH_TEST5`, `ETHERLINK`,
                                   `ETHERLINK_TEST`, `MANTLE`, `MANTLE_TEST`, `GUN_GUNZILLA`,
                                   `GUN_GUNZILLA_TEST`, `ETH_SONEIUM`, `SONEIUM_MINATO_TEST`,
                                   `IOTX_IOTEX`, `KLAY_KAIA`, `KLAY_KAIA_TEST`, `APECHAIN`,
                                   `APECHAIN_TEST`, `CRONOS`, `CRONOS_TEST`,
                                   `ROBINHOOD_CHAIN_TESTNET_TEST`
                                   """
                                 ],
                                 vaultAccountIds: [
                                   type: :string,
                                   doc:
                                     "Comma-separated vault account IDs to filter by (max 100). Ignored when `walletType` is `END_USER_WALLET` or `ncwId` is provided."
                                 ],
                                 ncwId: [
                                   type: :string,
                                   doc: "Tenant's Non-Custodial Wallet ID"
                                 ],
                                 ncwAccountIds: [
                                   type: :string,
                                   doc:
                                     "Comma-separated NCW account IDs (max 100). Ignored when `walletType` is `VAULT_ACCOUNT` or `ncwId` is not provided."
                                 ],
                                 walletType: [
                                   type: {:in, ["VAULT_ACCOUNT", "END_USER_WALLET"]},
                                   doc:
                                     "Wallet type — `\"VAULT_ACCOUNT\"` (default) or `\"END_USER_WALLET\"`"
                                 ],
                                 ids: [
                                   type: :string,
                                   doc:
                                     "Comma-separated Fireblocks NFT asset IDs to filter by (max 100)"
                                 ],
                                 collectionIds: [
                                   type: :string,
                                   doc: "Comma-separated collection IDs to filter by (max 100)"
                                 ],
                                 sort: [
                                   type: :string,
                                   doc:
                                     "Comma-separated sort field(s). Allowed values: `ownershipLastUpdateTime`, `name`, `collection.name`, `blockchainDescriptor`"
                                 ],
                                 order: [
                                   type: {:in, ["ASC", "DESC"]},
                                   doc: "Sort direction — `\"ASC\"` (default) or `\"DESC\"`"
                                 ],
                                 status: [
                                   type: {:in, ["LISTED", "ARCHIVED"]},
                                   doc:
                                     "Filter by ownership status — `\"LISTED\"` (default) or `\"ARCHIVED\"`"
                                 ],
                                 search: [
                                   type: :string,
                                   doc:
                                     "Search by token name/ID, collection name, or blockchain (max 100 chars)"
                                 ],
                                 spam: [
                                   type: :string,
                                   doc:
                                     "Filter by spam status — `\"true\"`, `\"false\"`, or `\"all\"`"
                                 ]
                               ] ++ @pagination

  @doc """
  Returns all tokens and their ownership data held in your workspace, with
  optional filtering and cursor-based pagination.

  Options:\n#{NimbleOptions.docs(@get_ownership_tokens_schema)}
  """
  @spec get_ownership_tokens(keyword()) :: map()
  def get_ownership_tokens(opts \\ []) do
    {:ok, params} = NimbleOptions.validate(opts, @get_ownership_tokens_schema)
    query_string = URI.encode_query(params)
    get!("#{@base_path}/ownership/tokens?#{query_string}")
  end

  @list_owned_tokens_schema [
                              ncwId: [
                                type: :string,
                                doc: "Tenant's Non-Custodial Wallet ID"
                              ],
                              walletType: [
                                type: {:in, ["VAULT_ACCOUNT", "END_USER_WALLET"]},
                                doc:
                                  "Wallet type — `\"VAULT_ACCOUNT\"` (default) or `\"END_USER_WALLET\"`"
                              ],
                              sort: [
                                type: :string,
                                doc: "Sort by field. Allowed values: `name`"
                              ],
                              order: [
                                type: {:in, ["ASC", "DESC"]},
                                doc: "Sort direction — `\"ASC\"` (default) or `\"DESC\"`"
                              ],
                              status: [
                                type: {:in, ["LISTED", "ARCHIVED"]},
                                doc:
                                  "Filter by ownership status — `\"LISTED\"` (default) or `\"ARCHIVED\"`"
                              ],
                              search: [
                                type: :string,
                                doc: "Search owned tokens by token name (max 100 chars)"
                              ],
                              spam: [
                                type: :string,
                                doc:
                                  "Filter by spam status — `\"true\"`, `\"false\"`, or `\"all\"`"
                              ]
                            ] ++ @pagination

  @doc """
  Returns all distinct tokens owned by the tenant (deduplicated across vault
  accounts), with optional filtering and cursor-based pagination.

  Options:\n#{NimbleOptions.docs(@list_owned_tokens_schema)}
  """
  @spec list_owned_tokens(keyword()) :: map()
  def list_owned_tokens(opts \\ []) do
    {:ok, params} = NimbleOptions.validate(opts, @list_owned_tokens_schema)
    query_string = URI.encode_query(params)
    get!("#{@base_path}/ownership/assets?#{query_string}")
  end

  @list_owned_collections_schema [
                                   ncwId: [
                                     type: :string,
                                     doc: "Tenant's Non-Custodial Wallet ID"
                                   ],
                                   walletType: [
                                     type: {:in, ["VAULT_ACCOUNT", "END_USER_WALLET"]},
                                     doc:
                                       "Wallet type — `\"VAULT_ACCOUNT\"` (default) or `\"END_USER_WALLET\"`"
                                   ],
                                   search: [
                                     type: :string,
                                     doc:
                                       "Search by collection name or contract address (max 100 chars)"
                                   ],
                                   sort: [
                                     type: :string,
                                     doc: "Sort by field. Allowed values: `name`"
                                   ],
                                   order: [
                                     type: {:in, ["ASC", "DESC"]},
                                     doc: "Sort direction — `\"ASC\"` (default) or `\"DESC\"`"
                                   ],
                                   status: [
                                     type: {:in, ["LISTED", "ARCHIVED"]},
                                     doc:
                                       "Filter by ownership status — `\"LISTED\"` (default) or `\"ARCHIVED\"`"
                                   ]
                                 ] ++ @pagination

  @doc """
  Returns all NFT collections held across the workspace, with optional
  filtering and cursor-based pagination.

  Options:\n#{NimbleOptions.docs(@list_owned_collections_schema)}
  """
  @spec list_owned_collections(keyword()) :: map()
  def list_owned_collections(opts \\ []) do
    {:ok, params} = NimbleOptions.validate(opts, @list_owned_collections_schema)
    query_string = URI.encode_query(params)
    get!("#{@base_path}/ownership/collections?#{query_string}")
  end

  @update_token_ownership_status_schema [
    status: [
      type: {:in, ["LISTED", "ARCHIVED"]},
      required: true,
      doc: "New ownership status — `\"LISTED\"` or `\"ARCHIVED\"`"
    ]
  ]

  @doc """
  Updates the ownership status of a single NFT across all tenant vaults.

  - `id`: Fireblocks NFT asset ID.
  - `idempotency_key`: Optional `X-Idempotency-Key` header value.

  Options:\n#{NimbleOptions.docs(@update_token_ownership_status_schema)}
  """
  @spec update_token_ownership_status(String.t(), keyword(), String.t()) :: any()
  def update_token_ownership_status(id, params, idempotency_key \\ "")
      when is_binary(id) do
    {:ok, opts} = NimbleOptions.validate(params, @update_token_ownership_status_schema)
    body = opts |> Enum.into(%{}) |> Jason.encode!()
    put!("#{@base_path}/ownership/tokens/#{id}/status", body, idempotency_key)
  end

  @doc """
  Updates the ownership status of multiple NFTs in a single request.

  Accepts a list of maps, each with:
  - `"assetId"` — Fireblocks NFT asset ID (required)
  - `"status"` — `"LISTED"` or `"ARCHIVED"` (required)

  - `idempotency_key`: Optional `X-Idempotency-Key` header value.

  ## Example

      FireblocksSdk.Api.Nft.update_tokens_ownership_status([
        %{"assetId" => "NFT-abc...", "status" => "ARCHIVED"},
        %{"assetId" => "NFT-def...", "status" => "LISTED"}
      ])
  """
  @spec update_tokens_ownership_status(list(map()), String.t()) :: any()
  def update_tokens_ownership_status(items, idempotency_key \\ "")
      when is_list(items) do
    body = Jason.encode!(items)
    put!("#{@base_path}/ownership/tokens/status", body, idempotency_key)
  end

  @doc """
  Updates the spam classification of multiple NFTs in a single request.

  Accepts a list of maps, each with:
  - `"assetId"` — Fireblocks NFT asset ID (required)
  - `"spam"` — `true` to mark as spam, `false` to unmark (required)

  - `idempotency_key`: Optional `X-Idempotency-Key` header value.

  ## Example

      FireblocksSdk.Api.Nft.update_tokens_ownership_spam([
        %{"assetId" => "NFT-abc...", "spam" => true},
        %{"assetId" => "NFT-def...", "spam" => false}
      ])
  """
  @spec update_tokens_ownership_spam(list(map()), String.t()) :: any()
  def update_tokens_ownership_spam(items, idempotency_key \\ "")
      when is_list(items) do
    body = Jason.encode!(items)
    put!("#{@base_path}/ownership/tokens/spam", body, idempotency_key)
  end
end
