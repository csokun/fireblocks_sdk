defmodule FireblocksSdk.API.Tap do
  import FireblocksSdk.Request

  @base_path "/v1/tap"

  @doc """
  Returns the active policy and its validation.
  """
  def active_policy() do
    get!("#{@base_path}/active_policy")
  end
end
