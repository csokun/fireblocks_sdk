defmodule FireblocksSdk.Api.Webhook do
  @moduledoc """
  Webhook V2 API module for Fireblocks SDK.
  """

  import FireblocksSdk.Request

  @base_path "/v1/webhooks"

  @webhook_v2_create_request [
    url: [type: :string, required: true],
    description: [type: :string],
    events: [type: {:list, :string}, required: true],
    enabled: [type: :boolean, default: false]
  ]

  @doc """
  Creates a new webhook, which will be triggered on the specified events

  **Endpoint Permission:** Owner, Admin, Non-Signing Admin.

  Options:\n#{NimbleOptions.docs(@webhook_v2_create_request)}
  """
  def create(webhook, idempotentKey \\ "") do
    {:ok, options} = NimbleOptions.validate(webhook, @webhook_v2_create_request)
    params = options |> Jason.encode!()
    post!("#{@base_path}", params, idempotentKey)
  end

  @webhook_v2_list_request [
    order: [type: {:in, [:asc, :desc]}, default: :desc, doc: "available value: `:asc`, `:desc`"],
    pageCursor: [type: :string],
    pageSize: [type: :integer, default: 10]
  ]

  @doc """
  Get all webhooks (paginated)

  Options:\n#{NimbleOptions.docs(@webhook_v2_list_request)}
  """
  def list(webhook) do
    {:ok, options} = NimbleOptions.validate(webhook, @webhook_v2_list_request)

    query_string =
      options
      |> atom_to_upper([:order])
      |> URI.encode_query()

    get!("#{@base_path}?#{query_string}")
  end

  @doc """
  Retrieve a webhook by its id
  """
  def get(webhook_id) when is_binary(webhook_id) do
    get!("#{@base_path}/#{webhook_id}")
  end

  @webhook_v2_update_request [
    url: [type: :string],
    description: [type: :string],
    events: [type: {:list, :string}],
    enabled: [type: :boolean, default: false]
  ]

  @doc """
  Update a webhook by its id

  **Endpoint Permission:** Owner, Admin, Non-Signing Admin.

  Options:\n#{NimbleOptions.docs(@webhook_v2_update_request)}
  """
  def update(webhook, idempotentKey \\ "") do
    {:ok, options} = NimbleOptions.validate(webhook, @webhook_v2_update_request)
    params = options |> Jason.encode!()
    patch!("#{@base_path}", params, idempotentKey)
  end

  @doc """
  Delete a webhook by its id

  **Endpoint Permission:** Owner, Admin, Non-Signing Admin.
  """
  def remove(webhook_id) when is_binary(webhook_id) do
    delete!("#{@base_path}/#{webhook_id}")
  end

  @webhook_v2_notifications_request [
    webhookId: [type: :string, required: true],
    sortBy: [
      type: {:in, [:id, :createdAt, :updatedAt, :status, :eventType, :resourceId]},
      doc:
        "Field to sort notifications by. Available values: `:id`, `:createdAt`, `:updatedAt`, `:status`, `:eventType`, `:resourceId`."
    ],
    order: [type: {:in, [:asc, :desc]}, doc: "available value: `:asc`, `:desc`"],
    pageCursor: [type: :string],
    pageSize: [type: :integer, default: 10],
    startTime: [
      type: :integer,
      doc:
        "Start time in milliseconds since epoch to filter by notifications created after this time (default 31 days ago)"
    ],
    endTime: [
      type: :integer,
      doc:
        "End time in milliseconds since epoch to filter by notifications created before this time (default current time)"
    ],
    statuses: [
      type: {:list, {:in, [:completed, :failed, :in_progress, :on_hold]}},
      doc:
        "Filter notifications by status. Available values: `:completed`, `:failed`, `:in_progress`, `:on_hold`."
    ],
    events: [
      type: {:list, :string},
      doc: """
      Available values : `transaction.created`, `transaction.status.updated`, `transaction.approval_status.updated`, `transaction.network_records.processing_completed`, `external_wallet.asset.added`, `external_wallet.asset.removed`, `internal_wallet.asset.added`, `internal_wallet.asset.removed`, `contract_wallet.asset.added`, `contract_wallet.asset.removed`, `vault_account.created`, `vault_account.asset.added`, `vault_account.asset.balance_updated`, `embedded_wallet.status.updated`, `embedded_wallet.created`, `embedded_wallet.asset.balance_updated`, `embedded_wallet.asset.added`, `embedded_wallet.account.created`, `embedded_wallet.device.added`, `onchain_data.updated`, `connection.added`, `connection.removed`, `connection.request.waiting_peer_approval`, `connection.request.rejected_by_peer`
      """
    ],
    resourceId: [type: :string]
  ]
  @doc """
  Get all notifications by webhook id (paginated)

  ```
  # Get notifications for a specific webhook
  FireblocksSdk.Api.Webhook.get_notifications([
    webhookId: "wh_123abc",
    order: :desc,
    events: ["transaction.created", "embedded_wallet.asset.added"],
    statuses: [:failed],
    pageSize: 20
  ])
  ```

  Options:\n#{NimbleOptions.docs(@webhook_v2_notifications_request)}
  """
  def get_notifications(webhook) do
    {:ok, options} = NimbleOptions.validate(webhook, @webhook_v2_notifications_request)

    webhook_id = options[:webhookId]

    query_string =
      options
      |> Keyword.delete(:webhookId)
      |> atom_to_upper([:order, :statuses])
      |> atom_to_string([:sortBy])
      |> URI.encode_query()

    get!("#{@base_path}/#{webhook_id}?#{query_string}")
  end

  @webhook_v2_get_notification_request [
    includeData: [
      type: :boolean,
      default: false,
      doc: "Whether to include notification data in the response."
    ],
    webhookId: [type: :string, required: true, doc: "The ID of the webhook to fetch"],
    notificationId: [type: :string, required: true, doc: "The ID of the notification to fetch"]
  ]

  @doc """
  Retrieve a specific notification by its id.

  Options:\n#{NimbleOptions.docs(@webhook_v2_get_notification_request)}
  """
  def get_notification(notification \\ []) do
    {:ok, options} = NimbleOptions.validate(notification, @webhook_v2_get_notification_request)

    webhook_id = options[:webhookId]
    notification_id = options[:notificationId]

    query_string =
      options
      |> Keyword.delete(:webhookId)
      |> Keyword.delete(:notificationId)
      |> URI.encode_query()

    get!("#{@base_path}/#{webhook_id}/notifications/#{notification_id}?#{query_string}")
  end

  @webhook_v2_get_notification_attempts_request [
    webhookId: [type: :string, required: true, doc: "The ID of the webhook to fetch"],
    notificationId: [type: :string, required: true, doc: "The ID of the notification to fetch"],
    pageCursor: [type: :string],
    pageSize: [type: :integer, default: 10]
  ]

  @doc """
  Get notification attempts by notification id

  Options:\n#{NimbleOptions.docs(@webhook_v2_get_notification_attempts_request)}
  """
  def get_notification_attempts(notification \\ []) do
    {:ok, options} =
      NimbleOptions.validate(notification, @webhook_v2_get_notification_attempts_request)

    webhook_id = options[:webhookId]
    notification_id = options[:notificationId]

    query_string =
      options
      |> Keyword.delete(:webhookId)
      |> Keyword.delete(:notificationId)
      |> URI.encode_query()

    get!("#{@base_path}/#{webhook_id}/notifications/#{notification_id}/attempts?#{query_string}")
  end

  @webhook_v2_resend_notification_request [
    webhookId: [
      type: :string,
      required: true,
      doc: "The ID of the webhook to resend notification for"
    ],
    notificationId: [type: :string, required: true, doc: "The ID of the notification to resend"]
  ]

  @doc """
  Resend a specific notification by its id.

  **Endpoint Permission:** Owner, Admin, Non-Signing Admin, Editor, Signer.

  Options:\n#{NimbleOptions.docs(@webhook_v2_resend_notification_request)}
  """
  def resend(notification \\ [], idempotentKey \\ "") do
    {:ok, options} = NimbleOptions.validate(notification, @webhook_v2_resend_notification_request)

    webhook_id = options[:webhookId]
    notification_id = options[:notificationId]

    post!(
      "#{@base_path}/#{webhook_id}/notifications/#{notification_id}/resend",
      "",
      idempotentKey
    )
  end

  @webhook_v2_resend_by_resource_request [
    webhookId: [
      type: :string,
      required: true,
      doc: "The ID of the webhook to resend notifications for"
    ],
    resourceId: [
      type: :string,
      required: true,
      doc: "The resource ID to resend notifications for"
    ],
    excludeStatuses: [
      type: {:list, {:in, [:completed, :failed, :in_progress, :on_hold]}},
      doc:
        "Filter notifications by status. Available values: `:completed`, `:failed`, `:in_progress`, `:on_hold`."
    ]
  ]

  @doc """
  Resend notifications by resource ID.

  **Endpoint Permission:** Owner, Admin, Non-Signing Admin, Editor, Signer.

  Options:\n#{NimbleOptions.docs(@webhook_v2_resend_by_resource_request)}
  """
  def resend_by_resource(notification \\ [], idempotentKey \\ "") do
    {:ok, options} = NimbleOptions.validate(notification, @webhook_v2_resend_by_resource_request)

    webhook_id = options[:webhookId]

    params =
      options
      |> Keyword.delete(:webhookId)
      |> atom_to_upper([:excludeStatuses])
      |> Jason.encode!()

    post!(
      "#{@base_path}/#{webhook_id}/notifications/resend_by_resource",
      params,
      idempotentKey
    )
  end

  @webhook_v2_resend_failed_request [
    webhookId: [
      type: :string,
      required: true,
      doc: "The ID of the webhook to resend failed notifications for"
    ],
    startTime: [
      type: :integer,
      doc:
        "Start time in milliseconds since epoch to filter by notifications created after this time (default 31 days ago)"
    ],
    events: [
      type: {:list, :string},
      doc: """
      Available values : `transaction.created`, `transaction.status.updated`, `transaction.approval_status.updated`, `transaction.network_records.processing_completed`, `external_wallet.asset.added`, `external_wallet.asset.removed`, `internal_wallet.asset.added`, `internal_wallet.asset.removed`, `contract_wallet.asset.added`, `contract_wallet.asset.removed`, `vault_account.created`, `vault_account.asset.added`, `vault_account.asset.balance_updated`, `embedded_wallet.status.updated`, `embedded_wallet.created`, `embedded_wallet.asset.balance_updated`, `embedded_wallet.asset.added`, `embedded_wallet.account.created`, `embedded_wallet.device.added`, `onchain_data.updated`, `connection.added`, `connection.removed`, `connection.request.waiting_peer_approval`, `connection.request.rejected_by_peer`
      """
    ]
  ]

  @doc """
  Resend all failed notifications for a webhook, optionally filtered by resource ID.

  **Endpoint Permission:** Owner, Admin, Non-Signing Admin, Editor, Signer.

  Options:\n#{NimbleOptions.docs(@webhook_v2_resend_failed_request)}
  """
  def resend_failed(notification \\ [], idempotentKey \\ "") do
    {:ok, options} = NimbleOptions.validate(notification, @webhook_v2_resend_failed_request)

    webhook_id = options[:webhookId]

    params =
      options
      |> Keyword.delete(:webhookId)
      |> Jason.encode!()

    post!(
      "#{@base_path}/#{webhook_id}/notifications/resend_failed",
      params,
      idempotentKey
    )
  end

  @doc """
  Get the status of a resend job
  """
  def get_resend_job_status(webhook_id, job_id)
      when is_binary(webhook_id)
      when is_binary(job_id) do
    get!("#{@base_path}/#{webhook_id}/notifications/resend_failed/jobs/#{job_id}")
  end
end
