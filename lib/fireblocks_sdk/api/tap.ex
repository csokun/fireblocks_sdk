defmodule FireblocksSdk.Api.Tap do
  import FireblocksSdk.Request

  @base_path "/v1/tap"
  @v2_base_path "/policy"

  # ---------------------------------------------------------------------------
  # Legacy (V1) endpoints
  # ---------------------------------------------------------------------------

  @doc """
  Returns the active policy and its validation (Legacy).

  Endpoint Permission: Admin, Non-Signing Admin, Signer, Approver, Editor, Viewer.
  """
  @deprecated "See Swagger spec for replacement"
  @spec active_policy() :: map()
  def active_policy() do
    get!("#{@base_path}/active_policy")
  end

  @doc """
  Returns the active draft and its validation (Legacy).

  Endpoint Permission: Admin, Non-Signing Admin, Signer, Approver, Editor, Viewer.
  """
  @deprecated "See Swagger spec for replacement"
  @spec get_draft() :: map()
  def get_draft() do
    get!("#{@base_path}/draft")
  end

  @update_draft_schema [
    rules: [
      type: {:list, :map},
      required: true,
      doc: "List of policy rule maps to set as the new draft."
    ]
  ]

  @doc """
  Update the draft with a new set of rules (Legacy).

  Endpoint Permission: Admin, Non-Signing Admin, Signer, Approver, Editor.

  Options:
  #{NimbleOptions.docs(@update_draft_schema)}
  """
  @deprecated "See Swagger spec for replacement"
  @spec update_draft(keyword(), String.t()) :: map()
  def update_draft(params, idempotency_key \\ "") do
    {:ok, options} = NimbleOptions.validate(params, @update_draft_schema)
    data = options |> Enum.into(%{}) |> Jason.encode!()
    put!("#{@base_path}/draft", data, idempotency_key)
  end

  @publish_draft_schema [
    draftId: [
      type: :string,
      required: true,
      doc: "The unique identifier of the draft to publish."
    ]
  ]

  @doc """
  Send a publish request for a draft by its ID (Legacy).

  Endpoint Permission: Admin, Non-Signing Admin, Signer, Approver, Editor.

  Options:
  #{NimbleOptions.docs(@publish_draft_schema)}
  """
  @deprecated "See Swagger spec for replacement"
  @spec publish_draft(keyword(), String.t()) :: map()
  def publish_draft(params, idempotency_key \\ "") do
    {:ok, options} = NimbleOptions.validate(params, @publish_draft_schema)
    data = options |> Enum.into(%{}) |> Jason.encode!()
    post!("#{@base_path}/draft", data, idempotency_key)
  end

  @publish_policy_rules_schema [
    rules: [
      type: {:list, :map},
      required: true,
      doc: "List of policy rule maps to publish directly."
    ]
  ]

  @doc """
  Publish a set of policy rules directly (Legacy).

  Endpoint Permission: Admin, Non-Signing Admin, Signer, Approver, Editor.

  Options:
  #{NimbleOptions.docs(@publish_policy_rules_schema)}
  """
  @deprecated "See Swagger spec for replacement"
  @spec publish_policy_rules(keyword(), String.t()) :: map()
  def publish_policy_rules(params, idempotency_key \\ "") do
    {:ok, options} = NimbleOptions.validate(params, @publish_policy_rules_schema)
    data = options |> Enum.into(%{}) |> Jason.encode!()
    post!("#{@base_path}/publish", data, idempotency_key)
  end

  # ---------------------------------------------------------------------------
  # Policy Editor V2 (Beta)
  # ---------------------------------------------------------------------------

  @get_active_policy_v2_schema [
    policyType: [
      type: {:list, :string},
      required: true,
      doc: """
      One or more policy types to filter by. Can be repeated for multiple types.
      Valid values: TRANSFER, STAKE, CONTRACT_CALL, TYPED_MESSAGE, APPROVE, MINT,
      BURN, RAW, COMPLIANCE, DEPLOYMENT, PROGRAM_CALL, DAPP_CONNECTION, UPGRADE,
      ORDER, AML_CHAINALYSIS_V2_SCREENING, AML_CHAINALYSIS_V2_POST_SCREENING,
      AML_ELLIPTIC_HOLISTIC_SCREENING, AML_ELLIPTIC_HOLISTIC_POST_SCREENING,
      TR_NOTABENE_SCREENING, TR_NOTABENE_POST_SCREENING.
      """
    ]
  ]

  @doc """
  Get the active policy and its validation by policy type (V2 Beta).

  Returns the active policy and its validation for a specific policy type.

  > Note: This endpoint is currently in beta and subject to change.
  > Contact your Fireblocks Customer Success Manager or send an email to csm@fireblocks.com.

  Endpoint Permissions: Owner, Admin, Non-Signing Admin.

  Options:
  #{NimbleOptions.docs(@get_active_policy_v2_schema)}
  """
  @spec get_active_policy_v2(keyword()) :: map()
  def get_active_policy_v2(params) do
    {:ok, options} = NimbleOptions.validate(params, @get_active_policy_v2_schema)
    query = options[:policyType] |> Enum.map_join("&", &"policyType=#{URI.encode_www_form(&1)}")
    get!("#{@v2_base_path}/active_policy?#{query}")
  end

  @get_draft_v2_schema [
    policyType: [
      type: {:list, :string},
      required: true,
      doc: """
      One or more policy types to filter by. Can be repeated for multiple types.
      Valid values: TRANSFER, STAKE, CONTRACT_CALL, TYPED_MESSAGE, APPROVE, MINT,
      BURN, RAW, COMPLIANCE, DEPLOYMENT, PROGRAM_CALL, DAPP_CONNECTION, UPGRADE,
      ORDER, AML_CHAINALYSIS_V2_SCREENING, AML_CHAINALYSIS_V2_POST_SCREENING,
      AML_ELLIPTIC_HOLISTIC_SCREENING, AML_ELLIPTIC_HOLISTIC_POST_SCREENING,
      TR_NOTABENE_SCREENING, TR_NOTABENE_POST_SCREENING.
      """
    ]
  ]

  @doc """
  Get the active draft by policy type (V2 Beta).

  Returns the active draft and its validation for a specific policy type.

  > Note: These endpoints are currently in beta and might be subject to changes.

  Endpoint Permissions: Owner, Admin, Non-Signing Admin.

  Options:
  #{NimbleOptions.docs(@get_draft_v2_schema)}
  """
  @spec get_draft_v2(keyword()) :: map()
  def get_draft_v2(params) do
    {:ok, options} = NimbleOptions.validate(params, @get_draft_v2_schema)
    query = options[:policyType] |> Enum.map_join("&", &"policyType=#{URI.encode_www_form(&1)}")
    get!("#{@v2_base_path}/draft?#{query}")
  end

  @update_draft_v2_schema [
    policyTypes: [
      type: {:list, :string},
      required: true,
      doc: """
      One or more policy types this draft applies to.
      Valid values: TRANSFER, STAKE, CONTRACT_CALL, TYPED_MESSAGE, APPROVE, MINT,
      BURN, RAW, COMPLIANCE, DEPLOYMENT, PROGRAM_CALL, DAPP_CONNECTION, UPGRADE,
      ORDER, AML_CHAINALYSIS_V2_SCREENING, AML_CHAINALYSIS_V2_POST_SCREENING,
      AML_ELLIPTIC_HOLISTIC_SCREENING, AML_ELLIPTIC_HOLISTIC_POST_SCREENING,
      TR_NOTABENE_SCREENING, TR_NOTABENE_POST_SCREENING.
      """
    ],
    rules: [
      type: {:list, :map},
      required: true,
      doc: "Array of V2 PolicyRule maps to set as the new draft."
    ]
  ]

  @doc """
  Update the draft with a new set of rules by policy types (V2 Beta).

  Updates the draft and returns its validation for specific policy types.

  > Note: These endpoints are currently in beta and might be subject to changes.

  Endpoint Permissions: Owner, Admin, Non-Signing Admin.

  Options:
  #{NimbleOptions.docs(@update_draft_v2_schema)}
  """
  @spec update_draft_v2(keyword(), String.t()) :: map()
  def update_draft_v2(params, idempotency_key \\ "") do
    {:ok, options} = NimbleOptions.validate(params, @update_draft_v2_schema)
    data = options |> Enum.into(%{}) |> Jason.encode!()
    put!("#{@v2_base_path}/draft", data, idempotency_key)
  end

  @publish_draft_v2_schema [
    policyTypes: [
      type: {:list, :string},
      required: true,
      doc: """
      One or more policy types this draft applies to.
      Valid values: TRANSFER, STAKE, CONTRACT_CALL, TYPED_MESSAGE, APPROVE, MINT,
      BURN, RAW, COMPLIANCE, DEPLOYMENT, PROGRAM_CALL, DAPP_CONNECTION, UPGRADE,
      ORDER, AML_CHAINALYSIS_V2_SCREENING, AML_CHAINALYSIS_V2_POST_SCREENING,
      AML_ELLIPTIC_HOLISTIC_SCREENING, AML_ELLIPTIC_HOLISTIC_POST_SCREENING,
      TR_NOTABENE_SCREENING, TR_NOTABENE_POST_SCREENING.
      """
    ],
    draftId: [
      type: :string,
      required: true,
      doc: "The unique identifier of the draft to publish."
    ]
  ]

  @doc """
  Send a publish request for a draft by ID and policy types (V2 Beta).

  Sends a publish request for a certain draft ID and returns the result.

  > Note: These endpoints are currently in beta and might be subject to changes.
  > Contact your Fireblocks Customer Success Manager or send an email to csm@fireblocks.com.

  Endpoint Permissions: Owner, Admin, Non-Signing Admin.

  Options:
  #{NimbleOptions.docs(@publish_draft_v2_schema)}
  """
  @spec publish_draft_v2(keyword(), String.t()) :: map()
  def publish_draft_v2(params, idempotency_key \\ "") do
    {:ok, options} = NimbleOptions.validate(params, @publish_draft_v2_schema)
    data = options |> Enum.into(%{}) |> Jason.encode!()
    post!("#{@v2_base_path}/draft", data, idempotency_key)
  end
end
