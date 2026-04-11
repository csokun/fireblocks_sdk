defmodule FireblocksSdk.Api.Tap do
  import FireblocksSdk.Request

  @base_path "/v1/tap"

  @doc """
  Returns the active policy and its validation (Legacy).
  """
  def active_policy() do
    get!("#{@base_path}/active_policy")
  end

  @doc """
  Returns the active draft and its validation (Legacy).
  """
  def get_draft() do
    get!("#{@base_path}/draft")
  end

  @doc """
  Update the draft with a new set of rules (Legacy).

  Accepts a map or keyword list with a `rules` key containing a list of policy rule maps.

  ## Example

      FireblocksSdk.Api.Tap.update_draft(%{rules: [%{type: "TRANSFER", ...}]})
  """
  def update_draft(params) when is_map(params) do
    put!("#{@base_path}/draft", Jason.encode!(params))
  end

  def update_draft(params) when is_list(params) do
    update_draft(Enum.into(params, %{}))
  end

  @doc """
  Send a publish request for a draft by its ID (Legacy).

  - `draft_id`: The unique identifier of the draft to publish.
  """
  def publish_draft(draft_id) when is_binary(draft_id) do
    body = %{draftId: draft_id} |> Jason.encode!()
    post!("#{@base_path}/draft", body)
  end

  @doc """
  Publish a set of policy rules directly (Legacy).

  Accepts a map or keyword list with a `rules` key containing a list of policy rule maps.

  ## Example

      FireblocksSdk.Api.Tap.publish_policy_rules(%{rules: [%{type: "TRANSFER", ...}]})
  """
  def publish_policy_rules(params) when is_map(params) do
    post!("#{@base_path}/publish", Jason.encode!(params))
  end

  def publish_policy_rules(params) when is_list(params) do
    publish_policy_rules(Enum.into(params, %{}))
  end
end
