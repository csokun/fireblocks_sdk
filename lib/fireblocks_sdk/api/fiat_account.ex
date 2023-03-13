defmodule FireblocksSdk.Api.FiatAccount do
  import FireblocksSdk.Request

  @base_path "/v1/fiat_accounts"

  @doc """
  List fiat accounts.
  """
  def get_accounts() do
    get!(@base_path)
  end

  @doc """
  Find a specific fiat account.
  """
  def get_account(accountId) do
    get!("#{@base_path}/#{accountId}")
  end

  @doc """
  Redeems funds to the linked DDA.
  """
  def redeem_to_linked_dda(accountId, amount, idempotentKey \\ "") do
    data = %{amount: amount} |> Jason.encode!()
    post!("#{@base_path}/#{accountId}/redeem_to_linked_dda", data, idempotentKey)
  end

  @doc """
  Deposits funds from the linked DDA.
  """
  def deposit_from_linked_dda(accountId, amount, idempotentKey \\ "") do
    data = %{amount: amount} |> Jason.encode!()
    post!("#{@base_path}/#{accountId}/deposit_from_linked_dda", data, idempotentKey)
  end
end
