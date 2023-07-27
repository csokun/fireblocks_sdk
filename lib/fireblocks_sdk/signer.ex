defmodule FireblocksSdk.Signer do
  @moduledoc false
  use Joken.Config

  def sign_jwt(path, body \\ %{}) do
    apiKey = Application.get_env(:fireblocks_sdk, :apiKey)
    apiSecret = Application.get_env(:fireblocks_sdk, :apiSecret)

    # support base64 secret
    secret =
      case Base.decode64(apiSecret) do
        {:ok, secret} -> secret
        _ -> apiSecret
      end

    claims = %{
      "uri" => path,
      "nonce" => UUID.uuid4(),
      "iat" => Joken.current_time(),
      "exp" => Joken.current_time() + 55,
      "sub" => apiKey,
      "bodyHash" => sha256(body)
    }

    signer = Joken.Signer.create("RS256", %{"pem" => secret})
    Joken.Signer.sign(claims, signer)
  end

  defp sha256(content) when is_map(content) do
    data = Jason.encode!(content)
    sha256(data)
  end

  defp sha256(content) when is_binary(content) do
    :crypto.hash(:sha256, content)
    |> Base.encode16(case: :lower)
  end
end
