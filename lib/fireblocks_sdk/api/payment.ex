defmodule FireblocksSdk.Api.Payment do
  import FireblocksSdk.Request

  @base_path "/v1/payments/xb-settlements"

  @doc """
  Get all coross-border (XB) settlement configurations.
  """
  def get_configs(), do: get!("#{@base_path}/configs")

  @doc """
  Get XB settlement configuration by id
  """
  def get_config(config_id) when is_binary(config_id) do
    get!("#{@base_path}/configs/#{config_id}")
  end

  @doc """
  Get a specific cross-border (XB) settlement flow.
  """
  def get_settlement_flow(flow_id) when is_binary(flow_id) do
    get!("#{@base_path}/flows/#{flow_id}")
  end
end
