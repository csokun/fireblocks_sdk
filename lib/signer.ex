defmodule FireblocksSdk.Signer do
  use Joken.Config

  def sign_jwt(path, body \\ %{}) do
    apiKey = Application.get_env(:fireblocks_sdk, :apiKey)
    apiSecret = Application.get_env(:fireblocks_sdk, :apiSecret)

    claims = %{
      "uri" => path,
      "nonce" => UUID.uuid4(),
      "iat" => Joken.current_time(),
      "exp" => Joken.current_time() + 55,
      "sub" => apiKey,
      "bodyHash" => sha256(body)
    }

    signer = Joken.Signer.create("RS256", %{"pem" => apiSecret})
    Joken.Signer.sign(claims, signer)
  end

  defp sha256(content) when is_map(content) do
    data = Jason.encode!(content)
    sha256(data)
  end

  defp sha256(content) when is_binary(content) do
    :crypto.hash(:sha256, content)
    |> Base.encode16()
  end
end
