defmodule FireblocksSdk.Api.Tags do
  @moduledoc """
  Fireblocks Tags API.

  Provides CRUD operations for workspace tags and tag approval request management.
  Tags can be attached to vault accounts to organize and group them.
  """

  import FireblocksSdk.Request

  @base_path "/v1/tags"

  @list_tags_schema [
    pageCursor: [
      type: :string,
      doc: "Page cursor for the next page of results"
    ],
    pageSize: [
      type: :non_neg_integer,
      doc: "Number of results per page (1–100, default 100)"
    ],
    label: [
      type: :string,
      doc: "Filter tags by label prefix"
    ],
    tagIds: [
      type: {:list, :string},
      doc: "Filter by specific tag IDs (max 100 UUIDs)"
    ],
    includePendingApprovalsInfo: [
      type: :boolean,
      default: false,
      doc: "Include pending approval info in results"
    ],
    isProtected: [
      type: :boolean,
      doc: "Filter by tag protection status"
    ]
  ]

  @doc """
  Returns a paginated list of all tags in the workspace, filtered by optional criteria.

  Options:\n#{NimbleOptions.docs(@list_tags_schema)}
  """
  def list(opts \\ []) do
    {:ok, params} = NimbleOptions.validate(opts, @list_tags_schema)

    query_string = URI.encode_query(params)
    get!("#{@base_path}?#{query_string}")
  end

  @create_tag_schema [
    label: [
      type: :string,
      required: true,
      doc: "The tag label (2–30 characters)"
    ],
    description: [
      type: :string,
      doc: "Tag description (max 250 characters)"
    ],
    color: [
      type: :string,
      doc: "Hex color code (e.g. `#FF5733`)"
    ],
    isProtected: [
      type: :boolean,
      default: false,
      doc: "Whether the tag is protected from modification by non-owners"
    ]
  ]

  @doc """
  Creates a new tag in the workspace.

  Options:\n#{NimbleOptions.docs(@create_tag_schema)}
  """
  def create(params) do
    {:ok, options} = NimbleOptions.validate(params, @create_tag_schema)
    body = options |> Enum.into(%{}) |> Jason.encode!()
    post!(@base_path, body)
  end

  @doc """
  Retrieves a single tag by its ID.

  - `tag_id`: UUID of the tag to retrieve
  """
  def get(tag_id) when is_binary(tag_id) do
    get!("#{@base_path}/#{tag_id}")
  end

  @update_tag_schema [
    label: [
      type: :string,
      doc: "The tag label"
    ],
    description: [
      type: :string,
      doc: "Tag description"
    ]
  ]

  @doc """
  Updates an existing tag's label or description.

  - `tag_id`: UUID of the tag to update

  Options:\n#{NimbleOptions.docs(@update_tag_schema)}
  """
  def update(tag_id, params) when is_binary(tag_id) do
    {:ok, options} = NimbleOptions.validate(params, @update_tag_schema)
    body = options |> Enum.into(%{}) |> Jason.encode!()
    patch!("#{@base_path}/#{tag_id}", body)
  end

  @doc """
  Deletes a tag from the workspace by its ID.

  - `tag_id`: UUID of the tag to delete
  """
  def delete(tag_id) when is_binary(tag_id) do
    delete!("#{@base_path}/#{tag_id}")
  end

  @doc """
  Retrieves a single tag approval request by its numeric ID.

  - `id`: Numeric string ID of the approval request
  """
  def get_approval_request(id) when is_binary(id) do
    get!("#{@base_path}/approval_requests/#{id}")
  end

  @doc """
  Cancels a pending tag approval request.

  Only PENDING approval requests can be cancelled. Returns 202 Accepted on success.

  - `id`: Numeric string ID of the approval request to cancel
  """
  def cancel_approval_request(id) when is_binary(id) do
    post!("#{@base_path}/approval_requests/#{id}/cancel", "")
  end
end
