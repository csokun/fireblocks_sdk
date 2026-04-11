defmodule FireblocksSdk.Api.Management do
  alias FireblocksSdk.Schema
  import FireblocksSdk.Request

  @base_path "/v1/management"

  @doc """
  Get api users from the current tenant
  """
  def get_api_users() do
    get!("#{@base_path}/api_users")
  end

  @doc """
  Create API User - admin permission is required

  Options: \n#{NimbleOptions.docs(Schema.create_api_user_request())}
  """
  def create_api_user(params) do
    {:ok, params} = NimbleOptions.validate(params, Schema.create_api_user_request())
    post!("#{@base_path}/api_users", params)
  end

  @doc """
  Get console users from the current tenant
  """
  def get_console_users() do
    get!("#{@base_path}/users")
  end

  @doc """
  Create Console User - admin permission is required

  Options: \n#{NimbleOptions.docs(Schema.create_console_user_request())}
  """
  def create_console_user(params) do
    {:ok, params} = NimbleOptions.validate(params, Schema.create_console_user_request())
    post!("#{@base_path}/users", params)
  end

  @doc """
  Reset device
  """
  def reset_device(user_id) when is_binary(user_id) do
    post!("#{@base_path}/users/#{user_id}/reset_device", "")
  end

  @doc """
  Get API user whitelist ip addresses from the current tenant
  """
  def get_api_user_whitelist_ip_addresses(user_id) when is_binary(user_id) do
    get!("#{@base_path}/api_users/#{user_id}/whitelist_ip_addresses")
  end
end
