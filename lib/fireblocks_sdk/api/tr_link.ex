defmodule FireblocksSdk.Api.TrLink do
  @moduledoc """
  Fireblocks TRLink API.

  Covers the TRSupport partner integration framework for Travel Rule compliance
  (`/v1/screening/trlink`). Manages customers (legal entities/VASPs), partner
  integrations, VASP discovery, asset support, and Travel Rule Message (TRM)
  lifecycle operations.
  """

  import FireblocksSdk.Request

  @base_path "/v1/screening/trlink"

  # ---------------------------------------------------------------------------
  # Shared pagination fields reused across query-param schemas in this module
  # ---------------------------------------------------------------------------

  @pagination [
    pageSize: [
      type: :non_neg_integer,
      default: 100,
      doc: "Number of items per page (min: 1, max: 100). Defaults to 100."
    ],
    pageCursor: [
      type: :string,
      doc: "Page cursor returned from a previous response's `paging.next` field."
    ]
  ]

  # ===========================================================================
  # Section 1 — Partners
  # ===========================================================================

  @doc """
  Returns list of available TRSupport partner integrations.
  """
  @spec get_tr_link_partners() :: list()
  def get_tr_link_partners() do
    get!("#{@base_path}/partners")
  end

  # ===========================================================================
  # Section 2 — Customers
  # ===========================================================================

  @doc """
  Creates a new TRLink customer with IVMS101-compliant identity data.

  Accepts a plain map containing IVMS101 customer identity fields.

  - `body`: IVMS101-compliant customer identity data.
  - `idempotency_key`: Optional `X-Idempotency-Key` header value.
  """
  @spec create_tr_link_customer(map(), String.t()) :: map()
  def create_tr_link_customer(body, idempotency_key \\ "") when is_map(body) do
    post!("#{@base_path}/customers", Jason.encode!(body), idempotency_key)
  end

  @doc """
  Returns a list of all TRLink customers.
  """
  @spec get_tr_link_customers() :: list()
  def get_tr_link_customers() do
    get!("#{@base_path}/customers")
  end

  @doc """
  Returns the TRLink customer with the given `customer_id`.

  - `customer_id`: The unique identifier of the customer.
  """
  @spec get_tr_link_customer(String.t()) :: map()
  def get_tr_link_customer(customer_id) when is_binary(customer_id) do
    get!("#{@base_path}/customers/#{customer_id}")
  end

  @doc """
  Partially updates a TRLink customer's IVMS101 identity data.

  Accepts a plain map containing the fields to update.

  - `customer_id`: The unique identifier of the customer.
  - `body`: Partial IVMS101 customer identity fields to update.
  - `idempotency_key`: Optional `X-Idempotency-Key` header value.
  """
  @spec update_tr_link_customer(String.t(), map(), String.t()) :: map()
  def update_tr_link_customer(customer_id, body, idempotency_key \\ "")
      when is_binary(customer_id) and is_map(body) do
    put!("#{@base_path}/customers/#{customer_id}", Jason.encode!(body), idempotency_key)
  end

  @doc """
  Deletes the TRLink customer with the given `customer_id`.

  - `customer_id`: The unique identifier of the customer.
  """
  @spec delete_tr_link_customer(String.t()) :: map()
  def delete_tr_link_customer(customer_id) when is_binary(customer_id) do
    delete!("#{@base_path}/customers/#{customer_id}")
  end

  # ===========================================================================
  # Section 3 — Integrations
  # ===========================================================================

  @doc """
  Returns all partner integrations for the given `customer_id`.

  - `customer_id`: The unique identifier of the customer.
  """
  @spec get_tr_link_customer_integrations(String.t()) :: list()
  def get_tr_link_customer_integrations(customer_id) when is_binary(customer_id) do
    get!("#{@base_path}/customers/#{customer_id}/integrations")
  end

  @doc """
  Returns a single partner integration by customer and integration IDs.

  - `customer_id`: The unique identifier of the customer.
  - `integration_id`: The unique identifier of the customer integration.
  """
  @spec get_tr_link_customer_integration(String.t(), String.t()) :: map()
  def get_tr_link_customer_integration(customer_id, integration_id)
      when is_binary(customer_id) and is_binary(integration_id) do
    get!("#{@base_path}/customers/#{customer_id}/integrations/#{integration_id}")
  end

  @doc """
  Creates a new TRLink partner integration.

  Accepts a plain map containing customer ID, partner ID, and optional integration ID.

  - `body`: Map with `customerId`, `partnerId`, and optionally `customerIntegrationId`.
  - `idempotency_key`: Optional `X-Idempotency-Key` header value.
  """
  @spec create_tr_link_integration(map(), String.t()) :: map()
  def create_tr_link_integration(body, idempotency_key \\ "") when is_map(body) do
    post!("#{@base_path}/customers/integration", Jason.encode!(body), idempotency_key)
  end

  @doc """
  Connects a TRLink integration by supplying API credentials for the partner.

  Accepts a plain map containing the partner API credentials.

  - `integration_id`: The unique identifier of the customer integration.
  - `body`: Map containing the partner API credentials.
  - `idempotency_key`: Optional `X-Idempotency-Key` header value.
  """
  @spec connect_tr_link_integration(String.t(), map(), String.t()) :: map()
  def connect_tr_link_integration(integration_id, body, idempotency_key \\ "")
      when is_binary(integration_id) and is_map(body) do
    put!(
      "#{@base_path}/customers/integration/#{integration_id}",
      Jason.encode!(body),
      idempotency_key
    )
  end

  @doc """
  Disconnects and removes the TRLink integration with the given `integration_id`.

  - `integration_id`: The unique identifier of the customer integration.
  """
  @spec disconnect_tr_link_integration(String.t()) :: map()
  def disconnect_tr_link_integration(integration_id) when is_binary(integration_id) do
    delete!("#{@base_path}/customers/integration/#{integration_id}")
  end

  @doc """
  Returns the partner's public key in JWK format for encrypting PII in Travel Rule messages.

  - `integration_id`: The unique identifier of the customer integration.
  """
  @spec get_tr_link_integration_public_key(String.t()) :: map()
  def get_tr_link_integration_public_key(integration_id) when is_binary(integration_id) do
    get!("#{@base_path}/customers/integration/#{integration_id}/public_key")
  end

  @doc """
  Tests the connection of a TRLink integration.

  Sends a test request to the partner using the stored credentials and returns
  the connection test result.

  - `integration_id`: The unique identifier of the customer integration.
  - `idempotency_key`: Optional `X-Idempotency-Key` header value.
  """
  @spec test_tr_link_integration_connection(String.t(), String.t()) :: map()
  def test_tr_link_integration_connection(integration_id, idempotency_key \\ "")
      when is_binary(integration_id) do
    post!(
      "#{@base_path}/customers/integration/#{integration_id}/test_connection",
      "",
      idempotency_key
    )
  end

  # ===========================================================================
  # Section 4 — VASPs
  # ===========================================================================

  @list_tr_link_vasps_schema @pagination

  @doc """
  Returns a paginated list of VASPs available through the given integration.

  - `integration_id`: The unique identifier of the customer integration.

  Options:
  #{NimbleOptions.docs(@list_tr_link_vasps_schema)}
  """
  @spec list_tr_link_vasps(String.t(), keyword()) :: map()
  def list_tr_link_vasps(integration_id, opts \\ []) when is_binary(integration_id) do
    {:ok, params} = NimbleOptions.validate(opts, @list_tr_link_vasps_schema)
    query_string = URI.encode_query(params)
    get!("#{@base_path}/customers/integration/#{integration_id}/vasps?#{query_string}")
  end

  @doc """
  Returns a single VASP by integration and VASP IDs.

  - `integration_id`: The unique identifier of the customer integration.
  - `vasp_id`: The unique identifier of the VASP.
  """
  @spec get_tr_link_vasp(String.t(), String.t()) :: map()
  def get_tr_link_vasp(integration_id, vasp_id)
      when is_binary(integration_id) and is_binary(vasp_id) do
    get!("#{@base_path}/customers/integration/#{integration_id}/vasps/#{vasp_id}")
  end

  # ===========================================================================
  # Section 5 — Assets
  # ===========================================================================

  @list_tr_link_supported_assets_schema @pagination

  @doc """
  Returns a paginated list of assets supported by the given integration.

  - `integration_id`: The unique identifier of the customer integration.

  Options:
  #{NimbleOptions.docs(@list_tr_link_supported_assets_schema)}
  """
  @spec list_tr_link_supported_assets(String.t(), keyword()) :: map()
  def list_tr_link_supported_assets(integration_id, opts \\ []) when is_binary(integration_id) do
    {:ok, params} = NimbleOptions.validate(opts, @list_tr_link_supported_assets_schema)
    query_string = URI.encode_query(params)
    get!("#{@base_path}/customers/integration/#{integration_id}/assets?#{query_string}")
  end

  @doc """
  Returns a single supported asset by integration and asset IDs.

  - `integration_id`: The unique identifier of the customer integration.
  - `asset_id`: The unique identifier of the asset.
  """
  @spec get_tr_link_supported_asset(String.t(), String.t()) :: map()
  def get_tr_link_supported_asset(integration_id, asset_id)
      when is_binary(integration_id) and is_binary(asset_id) do
    get!("#{@base_path}/customers/integration/#{integration_id}/assets/#{asset_id}")
  end

  # ===========================================================================
  # Section 6 — Travel Rule Messages (TRM)
  # ===========================================================================

  @doc """
  Assesses the Travel Rule reporting requirement for a transaction.

  Accepts a plain map containing transaction details for assessment.

  - `integration_id`: The unique identifier of the customer integration.
  - `body`: Map containing transaction details for Travel Rule assessment.
  - `idempotency_key`: Optional `X-Idempotency-Key` header value.
  """
  @spec assess_tr_link_travel_rule_requirement(String.t(), map(), String.t()) :: map()
  def assess_tr_link_travel_rule_requirement(integration_id, body, idempotency_key \\ "")
      when is_binary(integration_id) and is_map(body) do
    post!(
      "#{@base_path}/customers/integration/#{integration_id}/trm/assess",
      Jason.encode!(body),
      idempotency_key
    )
  end

  @doc """
  Creates a Travel Rule Message with IVMS101-compliant PII.

  Encrypts sensitive originator and beneficiary information before sending to the partner.
  Accepts a plain map containing IVMS101-compliant PII for originator and beneficiary.

  - `integration_id`: The unique identifier of the customer integration.
  - `body`: IVMS101-compliant PII for originator and beneficiary.
  - `idempotency_key`: Optional `X-Idempotency-Key` header value.
  """
  @spec create_tr_link_trm(String.t(), map(), String.t()) :: map()
  def create_tr_link_trm(integration_id, body, idempotency_key \\ "")
      when is_binary(integration_id) and is_map(body) do
    post!(
      "#{@base_path}/customers/integration/#{integration_id}/trm",
      Jason.encode!(body),
      idempotency_key
    )
  end

  @doc """
  Returns a Travel Rule Message by integration and TRM IDs.

  - `integration_id`: The unique identifier of the customer integration.
  - `trm_id`: The unique identifier of the Travel Rule Message.
  """
  @spec get_tr_link_trm(String.t(), String.t()) :: map()
  def get_tr_link_trm(integration_id, trm_id)
      when is_binary(integration_id) and is_binary(trm_id) do
    get!("#{@base_path}/customers/integration/#{integration_id}/trm/#{trm_id}")
  end

  @doc """
  Cancels a Travel Rule Message.

  Accepts a plain map containing the cancellation reason.

  - `integration_id`: The unique identifier of the customer integration.
  - `trm_id`: The unique identifier of the Travel Rule Message to cancel.
  - `body`: Map containing the cancellation reason.
  - `idempotency_key`: Optional `X-Idempotency-Key` header value.
  """
  @spec cancel_tr_link_trm(String.t(), String.t(), map(), String.t()) :: map()
  def cancel_tr_link_trm(integration_id, trm_id, body, idempotency_key \\ "")
      when is_binary(integration_id) and is_binary(trm_id) and is_map(body) do
    post!(
      "#{@base_path}/customers/integration/#{integration_id}/trm/#{trm_id}/cancel",
      Jason.encode!(body),
      idempotency_key
    )
  end

  @doc """
  Redirects a Travel Rule Message to a subsidiary VASP.

  Accepts a plain map containing target subsidiary VASP details.

  - `integration_id`: The unique identifier of the customer integration.
  - `trm_id`: The unique identifier of the Travel Rule Message to redirect.
  - `body`: Map containing target subsidiary VASP details.
  - `idempotency_key`: Optional `X-Idempotency-Key` header value.
  """
  @spec redirect_tr_link_trm(String.t(), String.t(), map(), String.t()) :: map()
  def redirect_tr_link_trm(integration_id, trm_id, body, idempotency_key \\ "")
      when is_binary(integration_id) and is_binary(trm_id) and is_map(body) do
    post!(
      "#{@base_path}/customers/integration/#{integration_id}/trm/#{trm_id}/redirect",
      Jason.encode!(body),
      idempotency_key
    )
  end

  # ===========================================================================
  # Section 7 — Policy
  # ===========================================================================

  @doc """
  Returns the complete TRSupport policy for the tenant, including pre-screening rules,
  post-screening rules, and missing TRM rules.
  """
  @spec get_tr_link_policy() :: map()
  def get_tr_link_policy() do
    get!("#{@base_path}/policy")
  end

  # ===========================================================================
  # Section 8 — Transaction TRM Association
  # ===========================================================================

  @doc """
  Associates a TRM ID with a Fireblocks transaction.

  Accepts a plain map containing the TRM ID to associate.

  - `tx_id`: The Fireblocks transaction ID.
  - `body`: Map containing the TRM ID to associate with the transaction.
  - `idempotency_key`: Optional `X-Idempotency-Key` header value.
  """
  @spec set_tr_link_transaction_trm_id(String.t(), map(), String.t()) :: map()
  def set_tr_link_transaction_trm_id(tx_id, body, idempotency_key \\ "")
      when is_binary(tx_id) and is_map(body) do
    post!(
      "#{@base_path}/transaction/#{tx_id}/travel_rule_message_id",
      Jason.encode!(body),
      idempotency_key
    )
  end

  @doc """
  Associates a TRM ID with a specific destination in a multi-destination transaction.

  Matches destination by amount and peer path. Accepts a plain map containing
  TRM ID and destination matching fields.

  - `tx_id`: The Fireblocks transaction ID.
  - `body`: Map containing TRM ID and destination matching fields (amount, peer path).
  - `idempotency_key`: Optional `X-Idempotency-Key` header value.
  """
  @spec set_tr_link_destination_trm_id(String.t(), map(), String.t()) :: map()
  def set_tr_link_destination_trm_id(tx_id, body, idempotency_key \\ "")
      when is_binary(tx_id) and is_map(body) do
    post!(
      "#{@base_path}/transaction/#{tx_id}/destination/travel_rule_message_id",
      Jason.encode!(body),
      idempotency_key
    )
  end
end
