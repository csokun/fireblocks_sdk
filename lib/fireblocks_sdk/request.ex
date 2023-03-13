defmodule FireblocksSdk.Request do
  alias FireblocksSdk.Signer

  @base_url "https://api.fireblocks.io"

  def get(path), do: request(:get, path)

  def get!(path) do
    [_, data, _] = get(path)
    data
  end

  def post(path, data, idempotentKey \\ "") do
    request(:post, path, data, idempotentKey)
  end

  def post!(path, data, idempotentKey \\ "") do
    [_, data, _] = post(path, data, idempotentKey)
    data
  end

  def put(path, data, idempotentKey \\ "") do
    request(:put, path, data, idempotentKey)
  end

  def put!(path, data, idempotentKey \\ "") do
    [_, data, _] = put(path, data, idempotentKey)
    data
  end

  def delete(path), do: request(:delete, path)

  def delete!(path) do
    [_, data, _] = delete(path)
    data
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

  defp request(method, path) do
    {:ok, token} = Signer.sign_jwt(path)

    url = "#{@base_url}#{path}"

    {:ok, response} =
      Finch.build(method, url, headers(token))
      |> Finch.request(FireblocksSdk.Finch)

    response
    |> parse_response()
  end

  defp request(method, path, data, idempotentKey) do
    {:ok, token} = Signer.sign_jwt(path, data)

    url = "#{@base_url}#{path}"

    headers =
      case idempotentKey do
        "" -> headers(token)
        key -> [{"Idempotency-Key", key} | headers(token)]
      end

    {:ok, response} =
      Finch.build(method, url, headers, data)
      |> Finch.request(FireblocksSdk.Finch)

    response
    |> parse_response()
  end

  defp parse_response(%Finch.Response{status: status, body: body, headers: headers}) do
    {:ok, data} = Jason.decode(body)
    [status, data, headers]
  end
end
