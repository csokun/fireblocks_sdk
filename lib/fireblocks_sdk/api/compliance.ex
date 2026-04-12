defmodule FireblocksSdk.Api.Compliance do
  @moduledoc """
  Fireblocks Compliance API.

  Covers two resource families:

  * **Address Registry** (`/v1/address_registry`) — manage workspace and per-vault
    opt-in/opt-out from the Fireblocks address registry.
  * **Screening** (`/v1/screening`) — read and update AML and Travel Rule screening
    policies, configurations, and transaction-level compliance operations.
  """

  import FireblocksSdk.Request

  @address_registry_base "/v1/address_registry"
  @screening_base "/v1/screening"

  # Shared screening config fields — used by both @update_travel_rule_config_schema
  # and @update_aml_screening_configuration_schema below.
  @screening_config_fields [
    bypassScreeningDuringServiceOutages: [
      type: :boolean,
      doc: "Enable/disable bypass during service outages"
    ],
    inboundTransactionDelay: [
      type: :non_neg_integer,
      doc: "Inbound transaction delay in seconds"
    ],
    outboundTransactionDelay: [
      type: :non_neg_integer,
      doc: "Outbound transaction delay in seconds"
    ]
  ]

  # ===========================================================================
  # Section 1 — Address Registry
  # ===========================================================================

  @get_legal_entity_by_address_schema [
    address: [type: :string, required: true, doc: "Blockchain address to look up"],
    asset: [type: :string, doc: "Optional asset identifier (e.g. \"ETH\")"]
  ]
  @deprecated "Use get_legal_entity_for_address/1 instead."
  @doc """
  Returns legal entity information associated with the given blockchain address.

  **Deprecated.** Use `get_legal_entity_for_address/1` instead.

  Options:\n#{NimbleOptions.docs(@get_legal_entity_by_address_schema)}
  """
  @spec get_legal_entity_by_address(keyword()) :: map()
  def get_legal_entity_by_address(opts) do
    {:ok, params} = NimbleOptions.validate(opts, @get_legal_entity_by_address_schema)
    query_string = params |> URI.encode_query()
    get!("#{@address_registry_base}/legal_entity?#{query_string}")
  end

  @doc """
  Returns legal entity information associated with the given blockchain address.

  - `address`: Blockchain address to look up
  """
  @spec get_legal_entity_for_address(String.t()) :: map()
  def get_legal_entity_for_address(address) when is_binary(address) do
    get!("#{@address_registry_base}/legal_entities/#{address}")
  end

  @doc """
  Returns the address registry opt-in status for the current tenant/workspace.
  """
  @spec get_address_registry_tenant_status() :: map()
  def get_address_registry_tenant_status() do
    get!("#{@address_registry_base}/tenant")
  end

  @doc """
  Opts the current tenant/workspace in to the Fireblocks address registry.

  - `idempotency_key`: Optional idempotency key
  """
  @spec opt_in_address_registry_tenant(String.t()) :: map()
  def opt_in_address_registry_tenant(idempotency_key \\ "") do
    post!("#{@address_registry_base}/tenant", "", idempotency_key)
  end

  @doc """
  Opts the current tenant/workspace out of the Fireblocks address registry.
  """
  @spec opt_out_address_registry_tenant() :: map()
  def opt_out_address_registry_tenant() do
    delete!("#{@address_registry_base}/tenant")
  end

  @list_address_registry_vault_opt_outs_schema [
    pageCursor: [type: :string, doc: "Cursor for paginated results"],
    pageSize: [
      type: :non_neg_integer,
      default: 50,
      doc: "Number of results per page (1–100)"
    ],
    order: [
      type: {:in, ["VAULT_OPT_OUT_LIST_ORDER_ASC", "VAULT_OPT_OUT_LIST_ORDER_DESC"]},
      doc:
        "Sort order. One of \"VAULT_OPT_OUT_LIST_ORDER_ASC\" or \"VAULT_OPT_OUT_LIST_ORDER_DESC\""
    ]
  ]
  @doc """
  Returns a paginated list of vault accounts that have opted out of the address registry.

  Options:\n#{NimbleOptions.docs(@list_address_registry_vault_opt_outs_schema)}
  """
  @spec list_address_registry_vault_opt_outs(keyword()) :: map()
  def list_address_registry_vault_opt_outs(opts \\ []) do
    {:ok, params} = NimbleOptions.validate(opts, @list_address_registry_vault_opt_outs_schema)
    query_string = params |> URI.encode_query()
    get!("#{@address_registry_base}/vaults?#{query_string}")
  end

  @add_address_registry_vault_opt_outs_schema [
    vaultAccountIds: [
      type: {:list, :string},
      required: true,
      doc: "Vault account IDs to add to the opt-out list"
    ]
  ]
  @doc """
  Adds one or more vault accounts to the address registry opt-out list.

  Options:\n#{NimbleOptions.docs(@add_address_registry_vault_opt_outs_schema)}
  """
  @spec add_address_registry_vault_opt_outs(keyword(), String.t()) :: map()
  def add_address_registry_vault_opt_outs(params, idempotency_key \\ "") do
    {:ok, opts} = NimbleOptions.validate(params, @add_address_registry_vault_opt_outs_schema)
    body = opts |> Enum.into(%{}) |> Jason.encode!()
    post!("#{@address_registry_base}/vaults", body, idempotency_key)
  end

  @doc """
  Removes all vault accounts from the address registry opt-out list.
  """
  @spec remove_all_address_registry_vault_opt_outs() :: map()
  def remove_all_address_registry_vault_opt_outs() do
    delete!("#{@address_registry_base}/vaults")
  end

  @doc """
  Returns the address registry opt-out status for the given vault account.

  - `vault_account_id`: The vault account ID to look up
  """
  @spec get_address_registry_vault_opt_out(String.t()) :: map()
  def get_address_registry_vault_opt_out(vault_account_id) when is_binary(vault_account_id) do
    get!("#{@address_registry_base}/vaults/#{vault_account_id}")
  end

  @doc """
  Removes the given vault account from the address registry opt-out list.

  - `vault_account_id`: The vault account ID to remove
  """
  @spec remove_address_registry_vault_opt_out(String.t()) :: map()
  def remove_address_registry_vault_opt_out(vault_account_id) when is_binary(vault_account_id) do
    delete!("#{@address_registry_base}/vaults/#{vault_account_id}")
  end

  # ===========================================================================
  # Section 2 — Screening Policy
  # ===========================================================================

  @doc """
  Returns the Travel Rule post-screening policy for the current workspace.
  """
  @spec get_travel_rule_post_screening_policy() :: map()
  def get_travel_rule_post_screening_policy() do
    get!("#{@screening_base}/travel_rule/post_screening_policy")
  end

  @doc """
  Returns the Travel Rule screening policy for the current workspace.
  """
  @spec get_travel_rule_screening_policy() :: map()
  def get_travel_rule_screening_policy() do
    get!("#{@screening_base}/travel_rule/screening_policy")
  end

  @doc """
  Returns the Travel Rule screening configuration for the current workspace.
  """
  @spec get_travel_rule_screening_configuration() :: map()
  def get_travel_rule_screening_configuration() do
    get!("#{@screening_base}/travel_rule/policy_configuration")
  end

  @update_travel_rule_config_schema @screening_config_fields
  @doc """
  Updates the Travel Rule screening configuration for the current workspace.

  Options:\n#{NimbleOptions.docs(@update_travel_rule_config_schema)}
  """
  @spec update_travel_rule_config(keyword(), String.t()) :: map()
  def update_travel_rule_config(params, idempotency_key \\ "") do
    {:ok, opts} = NimbleOptions.validate(params, @update_travel_rule_config_schema)
    body = opts |> Enum.into(%{}) |> Jason.encode!()
    put!("#{@screening_base}/travel_rule/policy_configuration", body, idempotency_key)
  end

  @doc """
  Returns the AML screening policy for the current workspace.
  """
  @spec get_aml_screening_policy() :: map()
  def get_aml_screening_policy() do
    get!("#{@screening_base}/aml/screening_policy")
  end

  @doc """
  Returns the AML post-screening policy for the current workspace.
  """
  @spec get_aml_post_screening_policy() :: map()
  def get_aml_post_screening_policy() do
    get!("#{@screening_base}/aml/post_screening_policy")
  end

  @doc """
  Returns the AML screening configuration for the current workspace.
  """
  @spec get_aml_screening_configuration() :: map()
  def get_aml_screening_configuration() do
    get!("#{@screening_base}/aml/policy_configuration")
  end

  @update_aml_screening_configuration_schema @screening_config_fields
  @doc """
  Updates the AML screening configuration for the current workspace.

  Options:\n#{NimbleOptions.docs(@update_aml_screening_configuration_schema)}
  """
  @spec update_aml_screening_configuration(keyword(), String.t()) :: map()
  def update_aml_screening_configuration(params, idempotency_key \\ "") do
    {:ok, opts} = NimbleOptions.validate(params, @update_aml_screening_configuration_schema)
    body = opts |> Enum.into(%{}) |> Jason.encode!()
    put!("#{@screening_base}/aml/policy_configuration", body, idempotency_key)
  end

  @update_screening_configuration_schema [
    disableBypass: [type: :boolean, doc: "Disable bypass screening"],
    disableUnfreeze: [type: :boolean, doc: "Disable unfreeze of frozen transactions"]
  ]
  @doc """
  Updates global screening configuration for the current workspace.

  Options:\n#{NimbleOptions.docs(@update_screening_configuration_schema)}
  """
  @spec update_screening_configuration(keyword(), String.t()) :: map()
  def update_screening_configuration(params, idempotency_key \\ "") do
    {:ok, opts} = NimbleOptions.validate(params, @update_screening_configuration_schema)
    body = opts |> Enum.into(%{}) |> Jason.encode!()
    put!("#{@screening_base}/configurations", body, idempotency_key)
  end

  @doc """
  Triggers a new outgoing transaction bypassing all screening checks. Admin API users only.

  - `tx_id`: Fireblocks transaction ID
  - `idempotency_key`: Optional idempotency key
  """
  @spec bypass_screening_policy(String.t(), String.t()) :: map()
  def bypass_screening_policy(tx_id, idempotency_key \\ "") when is_binary(tx_id) do
    post!(
      "#{@screening_base}/transaction/#{tx_id}/bypass_screening_policy",
      "",
      idempotency_key
    )
  end

  @doc """
  Returns full compliance details (AML + Travel Rule) for the given screened transaction.

  - `tx_id`: Fireblocks transaction ID
  """
  @spec get_screening_full_details(String.t()) :: map()
  def get_screening_full_details(tx_id) when is_binary(tx_id) do
    get!("#{@screening_base}/transaction/#{tx_id}")
  end

  @set_aml_verdict_schema [
    verdict: [
      type: {:in, ["ACCEPT", "REJECT"]},
      required: true,
      doc: "The compliance verdict. One of \"ACCEPT\" or \"REJECT\""
    ],
    txId: [type: :string, required: true, doc: "Fireblocks transaction ID"]
  ]
  @doc """
  Sets a manual AML verdict for a screened transaction.

  Options:\n#{NimbleOptions.docs(@set_aml_verdict_schema)}
  """
  @spec set_aml_verdict(keyword(), String.t()) :: map()
  def set_aml_verdict(params, idempotency_key \\ "") do
    {:ok, opts} = NimbleOptions.validate(params, @set_aml_verdict_schema)
    body = opts |> Enum.into(%{}) |> Jason.encode!()
    post!("#{@screening_base}/aml/verdict/manual", body, idempotency_key)
  end
end
