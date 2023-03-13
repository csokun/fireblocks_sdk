defmodule FireblocksSdk.Api.Webhook do
  import FireblocksSdk.Request

  @doc """
  Resends all failed webhook notifications.
  """
  def resend(txHash, created, updated, idempotentKey \\ "")
      when is_binary(txHash) and is_boolean(created) and is_boolean(updated) do
    params =
      %{
        resendCreated: created || true,
        resendStatusUpdated: updated || true
      }
      |> Jason.encode!()

    post!("/v1/webhook/resend/#{txHash}", params, idempotentKey)
  end

  def resend(idempotentKey \\ "") do
    post!("/v1/webhook/resend", "", idempotentKey)
  end
end
