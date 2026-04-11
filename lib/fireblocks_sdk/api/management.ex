defmodule FireblocksSdk.Api.Management do
  alias FireblocksSdk.Schema
  import FireblocksSdk.Request

  @base_path "/v1/management"

  # ---------------------------------------------------------------------------
  # API Users
  # ---------------------------------------------------------------------------

  @doc """
  Returns all API users in the current tenant.
  """
  def get_api_users() do
    get!("#{@base_path}/api_users")
  end

  @doc """
  Creates a new API user. Admin permission is required.

  Options:\n#{NimbleOptions.docs(Schema.create_api_user_request())}
  """
  def create_api_user(params) do
    {:ok, options} = NimbleOptions.validate(params, Schema.create_api_user_request())
    body = options |> Enum.into(%{}) |> Jason.encode!()
    post!("#{@base_path}/api_users", body)
  end

  @doc """
  Returns the whitelist IP addresses for a given API user.

  - `user_id`: The ID of the API user.
  """
  def get_api_user_whitelist_ip_addresses(user_id) when is_binary(user_id) do
    get!("#{@base_path}/api_users/#{user_id}/whitelist_ip_addresses")
  end

  # ---------------------------------------------------------------------------
  # Console Users
  # ---------------------------------------------------------------------------

  @doc """
  Returns all console users in the current tenant.
  """
  def get_console_users() do
    get!("#{@base_path}/users")
  end

  @doc """
  Creates a new console user. Admin permission is required.

  Options:\n#{NimbleOptions.docs(Schema.create_console_user_request())}
  """
  def create_console_user(params) do
    {:ok, options} = NimbleOptions.validate(params, Schema.create_console_user_request())
    body = options |> Enum.into(%{}) |> Jason.encode!()
    post!("#{@base_path}/users", body)
  end

  @doc """
  Resets the mobile device for a console user, requiring them to re-pair.

  - `user_id`: The ID of the console user whose device will be reset.
  """
  def reset_device(user_id) when is_binary(user_id) do
    post!("#{@base_path}/users/#{user_id}/reset_device", "")
  end

  # ---------------------------------------------------------------------------
  # User Groups
  # ---------------------------------------------------------------------------

  @doc """
  Returns a list of all user groups in the workspace.
  """
  def get_user_groups() do
    get!("#{@base_path}/user_groups")
  end

  @doc """
  Creates a new user group.

  Options:\n#{NimbleOptions.docs(Schema.user_group_create_request())}
  """
  def create_user_group(params) do
    {:ok, options} = NimbleOptions.validate(params, Schema.user_group_create_request())
    body = options |> Enum.into(%{}) |> Jason.encode!()
    post!("#{@base_path}/user_groups", body)
  end

  @doc """
  Returns a single user group by its ID.

  - `group_id`: The ID of the user group to retrieve.
  """
  def get_user_group(group_id) when is_binary(group_id) do
    get!("#{@base_path}/user_groups/#{group_id}")
  end

  @doc """
  Updates an existing user group's name or member list.

  - `group_id`: The ID of the user group to update.

  Options:\n#{NimbleOptions.docs(Schema.user_group_update_request())}
  """
  def update_user_group(group_id, params) when is_binary(group_id) do
    {:ok, options} = NimbleOptions.validate(params, Schema.user_group_update_request())
    body = options |> Enum.into(%{}) |> Jason.encode!()
    put!("#{@base_path}/user_groups/#{group_id}", body)
  end

  @doc """
  Deletes a user group by its ID.

  - `group_id`: The ID of the user group to delete.
  """
  def delete_user_group(group_id) when is_binary(group_id) do
    delete!("#{@base_path}/user_groups/#{group_id}")
  end

  # ---------------------------------------------------------------------------
  # Audit Logs
  # ---------------------------------------------------------------------------

  @doc """
  Returns audit logs for the last Day or Week.

  Options:\n#{NimbleOptions.docs(Schema.management_audit_logs_request())}
  """
  def get_audit_logs(opts \\ []) do
    {:ok, params} = NimbleOptions.validate(opts, Schema.management_audit_logs_request())

    query_string =
      params
      |> atom_to_upper([:timePeriod])
      |> URI.encode_query()

    get!("#{@base_path}/audit_logs?#{query_string}")
  end

  # ---------------------------------------------------------------------------
  # OTA (One Time Addresses)
  # ---------------------------------------------------------------------------

  @doc """
  Returns the current OTA (One Time Addresses) status for the workspace.
  """
  def get_ota_status() do
    get!("#{@base_path}/ota")
  end

  @doc """
  Enables or disables OTA (One Time Address) transactions for the workspace.

  - `enabled`: `true` to enable OTA transactions, `false` to disable.
  """
  def set_ota_status(enabled) when is_boolean(enabled) do
    body = %{enabled: enabled} |> Jason.encode!()
    put!("#{@base_path}/ota", body)
  end

  # ---------------------------------------------------------------------------
  # Workspace Status
  # ---------------------------------------------------------------------------

  @doc """
  Returns the current workspace status (Beta).
  """
  def get_workspace_status() do
    get!("#{@base_path}/workspace_status")
  end
end
