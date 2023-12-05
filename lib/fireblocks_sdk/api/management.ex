defmodule FireblocksSdk.Api.Management do
  alias FireblocksSdk.Schema
  import FireblocksSdk.Request

  @base_path "/v1/management"

  @doc """
  Get api users from the current tenant
  """
  def get_api_users() do
    get!("#{@base_path}/api-users")
  end

  @doc """
  Create API User - admin permission is required
  """
  def create_api_user(params) do
    {:ok, params} = NimbleOptions.validate(params, Schema.create_api_user_request())
    post!("#{@base_path}/api-users", params)
  end

  @doc """
  Get console users from the current tenant
  """
  def get_console_users() do
    get!("#{@base_path}/console-users")
  end

  @doc """
  Create Console User - admin permission is required
  """
  def create_console_user(params) do
    {:ok, params} = NimbleOptions.validate(params, Schema.create_console_user_request())
    post!("#{@base_path}/console-users", params)
  end

  @doc """
  Reset device
  """
  def reset_device(user_id) when is_binary(user_id) do
    post!("#{@base_path}/console-users/#{user_id}/reset-device", [])
  end

  @doc """
  Get API user whitelist ip addresses from the current tenant
  """
  def get_api_user_whitelist_ip_addresses(user_id) when is_binary(user_id) do
    get!("#{@base_path}/api-users/#{user_id}/whitelist-ip-addresses")
  end
end
