defmodule FireblocksSdk.Request do
  alias FireblocksSdk.Signer

  @base_url "https://api.fireblocks.io"

  def get(path) do
    {:ok, token} = Signer.sign_jwt(path)

    url = "#{@base_url}#{path}"

    {:ok, response} =
      Finch.build(:get, url, headers(token))
      |> Finch.request(FireblocksSdk.Finch)

    response
    |> parse_response()
  end

  def post(path, data, idempotentKey \\ "") do
    {:ok, token} = Signer.sign_jwt(path, data)

    url = "#{@base_url}#{path}"

    headers =
      case idempotentKey do
        "" -> headers(token)
        key -> [{"Idempotency-Key", key} | headers(token)]
      end
      |> IO.inspect()

    {:ok, response} =
      Finch.build(:post, url, headers, data)
      |> Finch.request(FireblocksSdk.Finch)

    response
    |> parse_response()
  end

  def atom_to_string(params, props) do
    atom_transform(params, props, &Atom.to_string/1)
  end

  def atom_to_upper(params, props) do
    atom_transform(params, props, fn item ->
      Atom.to_string(item)
      |> String.upcase()
    end)
  end

  defp atom_transform(params, props, transformer) do
    props
    |> Enum.reduce(params, fn prop, acc ->
      prop =
        cond do
          is_atom(prop) -> [prop]
          is_list(prop) -> prop
        end

      case get_in(acc, prop) do
        nil ->
          acc

        _ ->
          update_in(acc, prop, &transformer.(&1))
      end
    end)
  end

  defp headers(token) do
    api_key = Application.get_env(:fireblocks_sdk, :apiKey)
    agent = "fireblocks-sdk-js/4.0.0"

    [
      {"X-API-Key", api_key},
      {"User-Agent", agent},
      {"Content-Type", "application/json"},
      {"Authorization", "Bearer #{token}"}
    ]
  end

  defp parse_response(%Finch.Response{status: status, body: body, headers: headers}) do
    {:ok, data} = Jason.decode(body)
    [status, data, headers]
  end
end
