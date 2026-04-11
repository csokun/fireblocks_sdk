defmodule FireblocksSdk.Api.Tap do
  import FireblocksSdk.Request

  @base_path "/v1/tap"

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
end
