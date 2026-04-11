# Fireblocks SDK

## Project Overview
This is an Elixir SDK for the Fireblocks API. It is generated/maintained against the official OpenAPI/Swagger specification.

**Core Principle:** The Swagger specification (`swagger.json`) is the **single source of truth**. All Elixir modules, types, and documentation must strictly reflect the current state of the spec.

## Key Resources
- **Swagger Spec:** `https://docs.fireblocks.com/api/v1/swagger.json`
- **Source Code:** `lib/`
- **Tests:** `test/`

## Workflow for Adding/Updating Features

### 1. Analysis Phase
- **Fetch Latest Spec:** Always download the latest `swagger.json` from the URL above (if `swagger.json` file is not found in the root folder)
- **Diff Check:** Compare the new spec with the previous version (or existing code) to identify:
  - New endpoints
  - Changed request/response schemas
  - Deprecated fields
- **Map to Elixir:** Identify corresponding Elixir modules in `lib/fireblocks_sdk/`.

### 2. Implementation Rules
- **Module Structure:** Mirror the API `tags` or path hierarchy (e.g., `FireblocksSdk.Vault.Assets`).
- **Validation & Types (`NimbleOptions`):**
  - **Colocation:** Define a `@<function>_schema` module attribute using `NimbleOptions` directly above the `@doc` of the function that uses it. For example, `create/2` → `@create_schema`, `list/1` → `@list_schema`, `update_settings/2` → `@update_settings_schema`.
  - **Naming convention:** Always use the `@<function>_schema` naming pattern. Never use a generic `@options_schema` or an unrelated name, and never reuse the same attribute name for two different functions in the same module (silent shadowing).
  - **Shared Schemas:** If a schema is genuinely reused across **more than one module**, define it as a public function in `FireblocksSdk.Schema` and call it from each module. Do **not** duplicate it inline — keep `FireblocksSdk.Schema` as the single source of truth for cross-module schemas.
  - **Shared sub-fields within a module:** If multiple schemas in the same module share a common set of fields (e.g., pagination parameters), define a private `@<name>` module attribute (e.g., `@pagination`) at the top of the module and compose schemas with `++ @pagination`.
  - **Mapping:**
    - Map Swagger `required` fields to `required: true` in NimbleOptions.
    - Map Swagger types (`string`, `integer`, `boolean`) to corresponding Elixir types in `NimbleOptions`.
    - Use `NimbleOptions.validate/2` at the start of public functions to enforce contract compliance.
- **Function Signatures:**
  - **Naming:** Derive from `operationId` (preferred) or path segments, converted to `snake_case`.
  - **Arguments:**
    - Positional args for required path parameters.
    - Single keyword list arg for optional query params and body data (validated against the function's `@<function>_schema`).
- **Documentation:**
  - **Sync:** Copy `summary` and `description` from Swagger into `@doc`.
  - **Specs:** Include `@spec` reflecting the validated input (keyword list) and the decoded response struct/map.
  - **Deprecation:** Add `@deprecated "See Swagger spec for replacement"` if marked in the spec.
- **POST/PUT:** convert NimbleOption parsed value into %{} using `Enum.into(%{})` before encode it to json

```elixir
    def function_one(params, idempotentKey \\ "") do
      {:ok, params} = NimbleOptions.validate(params, @function_one_schema)
      data = params |> Enum.into(%{}) |> Jason.encode!()
      post!("endpoint path", data, idempotentKey)
    end
```

### 3. Validation
- **Compile:** Ensure `mix compile` passes with no warnings.
- **Dialyzer:** Run `mix dialyzer` to verify type consistency between spec and implementation.
- **Tests:**
  - Update mocks/fixtures to match new schema structures.
  - Ensure all new public functions have test coverage.

## Specific Elixir Conventions
- **JSON Encoding/Decoding:** Use `Jason` (or project default). Ensure atom keys are handled correctly if using `keys: :atoms`.
- **Error Handling:** Return `{:ok, result}` or `{:error, reason}` tuples. Map HTTP errors to structured Elixir exceptions or error tuples as defined in `lib/fireblocks_sdk/error.ex`.
- **Naming:**
  - Modules: `FireblocksSdk.Vault.Assets` (nested by tag/path).
  - Functions: `list_vault_accounts/1`, `create_transaction/2`.

## Maintenance Checklist
- [ ] Did you fetch the latest `swagger.json`?
- [ ] Are all `@spec` types aligned with the Swagger schema?
- [ ] Is the `@doc` content synced with the Swagger description?
- [ ] Did you handle deprecated fields/endpoints correctly?
- [ ] Do tests pass with the new structure?
