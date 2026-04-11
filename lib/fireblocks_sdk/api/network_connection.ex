defmodule FireblocksSdk.Api.NetworkConnection do
  @moduledoc """
  Fireblocks Network Connections API.

  Covers two resource families within the "Network connections" tag:

  * **Network Connections** (`/v1/network_connections`) — peer-to-peer connections
    between Fireblocks workspaces.
  * **Network IDs** (`/v1/network_ids`) — local and remote discoverable network
    identifiers used to establish those connections.

  Routing policies (passed as plain `map()` values) support three destination
  schemes:
  * `%{"scheme" => "CUSTOM", "dstType" => "VAULT"|"EXCHANGE"|"FIAT_ACCOUNT", "dstId" => id}`
  * `%{"scheme" => "DEFAULT"}` — available for network-connection policies only
  * `%{"scheme" => "NONE"}`
  """

  import FireblocksSdk.Request

  @base_connections "/v1/network_connections"
  @base_ids "/v1/network_ids"

  # ---------------------------------------------------------------------------
  # Shared pagination fields reused across query-param schemas
  # ---------------------------------------------------------------------------

  @pagination [
    pageCursor: [
      type: :string,
      doc: "Cursor for the next page of results"
    ],
    pageSize: [
      type: :non_neg_integer,
      doc: "Number of records per page (1–50, default 50)"
    ]
  ]

  # ===========================================================================
  # Network Connections  —  /v1/network_connections
  # ===========================================================================

  @doc """
  Returns all network connections.

  Subject to Flexible Routing Schemes. Each connection includes a routing policy
  that controls how outgoing transactions are dispatched — `None`, `Custom`, or
  `Default`.
  """
  @spec get_network_connections() :: list()
  def get_network_connections() do
    get!(@base_connections)
  end

  @create_network_connection_schema [
    localNetworkId: [
      type: :string,
      required: true,
      doc: "Network ID of the profile initiating the connection"
    ],
    remoteNetworkId: [
      type: :string,
      required: true,
      doc: "Network ID the profile is connecting to"
    ],
    routingPolicy: [
      type: :map,
      doc:
        "Map of asset-group → routing destination (`CustomRoutingDest`, `DefaultNetworkRoutingDest`, or `NoneNetworkRoutingDest`)"
    ]
  ]

  @doc """
  Creates a new network connection.

  Initiates a connection between the local workspace's network ID and a remote
  network ID. Subject to Flexible Routing Schemes. When custom routing is chosen
  but no destination is specified it defaults to `dstId=0, dstType=VAULT`.

  - `idempotency_key`: Optional idempotency key (`X-Idempotency-Key` header).

  Options:\n#{NimbleOptions.docs(@create_network_connection_schema)}
  """
  @spec create_network_connection(keyword(), String.t()) :: map()
  def create_network_connection(params, idempotency_key \\ "") do
    {:ok, options} = NimbleOptions.validate(params, @create_network_connection_schema)
    body = options |> Enum.into(%{}) |> Jason.encode!()
    post!(@base_connections, body, idempotency_key)
  end

  @doc """
  Returns a single network connection by its ID.

  - `connection_id`: The ID of the network connection.
  """
  @spec get_network_connection(String.t()) :: map()
  def get_network_connection(connection_id) when is_binary(connection_id) do
    get!("#{@base_connections}/#{connection_id}")
  end

  @doc """
  Deletes an existing network connection by its ID.

  - `connection_id`: The ID of the network connection to delete.
  """
  @spec delete_network_connection(String.t()) :: map()
  def delete_network_connection(connection_id) when is_binary(connection_id) do
    delete!("#{@base_connections}/#{connection_id}")
  end

  @set_routing_policy_schema [
    routingPolicy: [
      type: :map,
      required: true,
      doc:
        "New routing policy — map of asset-group → routing destination (`CustomRoutingDest`, `DefaultNetworkRoutingDest`, or `NoneNetworkRoutingDest`)"
    ]
  ]

  @doc """
  Updates the routing policy of an existing network connection.

  - `connection_id`: The ID of the network connection to update.

  Options:\n#{NimbleOptions.docs(@set_routing_policy_schema)}
  """
  @spec set_routing_policy(String.t(), keyword()) :: map()
  def set_routing_policy(connection_id, params) when is_binary(connection_id) do
    {:ok, options} = NimbleOptions.validate(params, @set_routing_policy_schema)
    body = options |> Enum.into(%{}) |> Jason.encode!()
    patch!("#{@base_connections}/#{connection_id}/set_routing_policy", body)
  end

  @doc """
  Validates whether future transactions on a given connection are routed to the
  displayed recipient or to a third party.

  - `connection_id`: The ID of the network connection.
  - `asset_type`: The destination asset type to check (e.g. `"ETH"`).
  """
  @spec check_third_party_routing(String.t(), String.t()) :: map()
  def check_third_party_routing(connection_id, asset_type)
      when is_binary(connection_id) and is_binary(asset_type) do
    get!("#{@base_connections}/#{connection_id}/is_third_party_routing/#{asset_type}")
  end

  # ===========================================================================
  # Network IDs  —  /v1/network_ids
  # ===========================================================================

  @doc """
  Returns all local and discoverable remote network IDs.

  > #### Deprecated {: .warning}
  > This endpoint is deprecated. Use `search_network_ids/1` instead.
  """
  @deprecated "Use search_network_ids/1 instead. See Fireblocks swagger spec for details."
  @spec get_network_ids() :: list()
  def get_network_ids() do
    get!(@base_ids)
  end

  @create_network_id_schema [
    name: [
      type: :string,
      required: true,
      doc: "Display name for the new network ID"
    ],
    routingPolicy: [
      type: :map,
      doc:
        "Map of asset-group → routing destination. Supports `CustomRoutingDest` or `NoneNetworkRoutingDest` only (no `DEFAULT` scheme)"
    ]
  ]

  @doc """
  Creates a new Network ID.

  - `idempotency_key`: Optional idempotency key (`X-Idempotency-Key` header).

  Options:\n#{NimbleOptions.docs(@create_network_id_schema)}
  """
  @spec create_network_id(keyword(), String.t()) :: map()
  def create_network_id(params, idempotency_key \\ "") do
    {:ok, options} = NimbleOptions.validate(params, @create_network_id_schema)
    body = options |> Enum.into(%{}) |> Jason.encode!()
    post!(@base_ids, body, idempotency_key)
  end

  @doc """
  Returns all enabled routing policy asset groups for the workspace.

  Asset groups are the keys used in routing policy maps (e.g. `"ETH"`,
  `"BTC"`, `"ERC20"`).
  """
  @spec get_routing_policy_asset_groups() :: list()
  def get_routing_policy_asset_groups() do
    get!("#{@base_ids}/routing_policy_asset_groups")
  end

  @search_network_ids_schema [
                               search: [
                                 type: :string,
                                 doc:
                                   "Filter results by displayName or networkId (minimum 1 character)"
                               ],
                               excludeSelf: [
                                 type: :boolean,
                                 doc:
                                   "When `true`, excludes your own workspace's network IDs from results"
                               ],
                               onlySelf: [
                                 type: :boolean,
                                 doc: "When `true`, returns only your own workspace's network IDs"
                               ],
                               excludeConnected: [
                                 type: :boolean,
                                 doc:
                                   "When `true`, excludes network IDs that already have an active connection"
                               ]
                             ] ++ @pagination

  @doc """
  Returns both local and discoverable remote network IDs with optional filtering.

  This is the preferred replacement for the deprecated `get_network_ids/0`.

  Options:\n#{NimbleOptions.docs(@search_network_ids_schema)}
  """
  @spec search_network_ids(keyword()) :: map()
  def search_network_ids(opts \\ []) do
    {:ok, params} = NimbleOptions.validate(opts, @search_network_ids_schema)
    query_string = URI.encode_query(params)
    get!("#{@base_ids}/search?#{query_string}")
  end

  @doc """
  Returns a specific network ID by its ID.

  - `network_id`: The ID of the network to retrieve.
  """
  @spec get_network_id(String.t()) :: map()
  def get_network_id(network_id) when is_binary(network_id) do
    get!("#{@base_ids}/#{network_id}")
  end

  @doc """
  Deletes a network ID by its ID.

  - `network_id`: The ID of the network to delete.
  """
  @spec delete_network_id(String.t()) :: map()
  def delete_network_id(network_id) when is_binary(network_id) do
    delete!("#{@base_ids}/#{network_id}")
  end

  @set_network_id_routing_policy_schema [
    routingPolicy: [
      type: :map,
      required: true,
      doc:
        "New routing policy — map of asset-group → routing destination. Supports `CustomRoutingDest` or `NoneNetworkRoutingDest` only"
    ]
  ]

  @doc """
  Updates the routing policy of a specified network ID.

  - `network_id`: The ID of the network to update.

  Options:\n#{NimbleOptions.docs(@set_network_id_routing_policy_schema)}
  """
  @spec set_network_id_routing_policy(String.t(), keyword()) :: map()
  def set_network_id_routing_policy(network_id, params) when is_binary(network_id) do
    {:ok, options} = NimbleOptions.validate(params, @set_network_id_routing_policy_schema)
    body = options |> Enum.into(%{}) |> Jason.encode!()
    patch!("#{@base_ids}/#{network_id}/set_routing_policy", body)
  end

  @set_network_id_discoverability_schema [
    isDiscoverable: [
      type: :boolean,
      required: true,
      doc: "Whether this network ID should be visible and discoverable by other workspaces"
    ]
  ]

  @doc """
  Updates the discoverability setting of a network ID.

  When `isDiscoverable` is `true`, other workspaces can find and connect to this
  network ID. When `false`, it is hidden from remote searches.

  - `network_id`: The ID of the network to update.

  Options:\n#{NimbleOptions.docs(@set_network_id_discoverability_schema)}
  """
  @spec set_network_id_discoverability(String.t(), keyword()) :: map()
  def set_network_id_discoverability(network_id, params) when is_binary(network_id) do
    {:ok, options} = NimbleOptions.validate(params, @set_network_id_discoverability_schema)
    body = options |> Enum.into(%{}) |> Jason.encode!()
    patch!("#{@base_ids}/#{network_id}/set_discoverability", body)
  end

  @set_network_id_name_schema [
    name: [
      type: :string,
      required: true,
      doc: "New display name for the network ID"
    ]
  ]

  @doc """
  Updates the display name of a specified network ID.

  - `network_id`: The ID of the network to rename.

  Options:\n#{NimbleOptions.docs(@set_network_id_name_schema)}
  """
  @spec set_network_id_name(String.t(), keyword()) :: map()
  def set_network_id_name(network_id, params) when is_binary(network_id) do
    {:ok, options} = NimbleOptions.validate(params, @set_network_id_name_schema)
    body = options |> Enum.into(%{}) |> Jason.encode!()
    patch!("#{@base_ids}/#{network_id}/set_name", body)
  end
end
