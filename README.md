# Fireblocks SDK

**Un-official** Elixir [Fireblocks API](https://docs.fireblocks.com/api/swagger-ui) Client.

## Installation

Adding `fireblocks_sdk` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:fireblocks_sdk, "~> 0.1.5"}
  ]
end
```

## Config

```elixir
config :fireblocks_sdk,
  apiKey: "",
  apiSecret: """
  -----BEGIN RSA PRIVATE KEY-----
  --api-secret-key-goes-here--
  -----END RSA PRIVATE KEY-----
  """
```
