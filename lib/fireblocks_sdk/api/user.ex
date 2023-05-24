defmodule FireblocksSdk.Api.User do
  import FireblocksSdk.Request

  @base_path "/v1/users"

  @doc """
  Only work if API key has role Admin
  """
  def users() do
    get!(@base_path)
  end
end
