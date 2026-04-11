defmodule FireblocksSdk.Api.Workspace do
  import FireblocksSdk.Request

  @base_path "/v1/workspace"

  @doc """
  Returns the workspace ID and name for the authenticated user.
  """
  def get_workspace() do
    get!(@base_path)
  end

  @doc """
  Freezes a Workspace so ALL operations by ANY user are blocked.

  > **Warning:** This is a destructive operation. Once frozen, the workspace can
  > only be unfrozen by contacting Fireblocks Support. Only workspace Admins
  > may call this endpoint.
  """
  def freeze_workspace() do
    post!("#{@base_path}/freeze", "")
  end
end
