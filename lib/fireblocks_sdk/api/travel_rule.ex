defmodule FireblocksSdk.Api.TravelRule do
  @moduledoc """
  Fireblocks Travel Rule API.

  Covers VASP discovery, transaction validation, vault VASP assignment,
  and TRUST network proof-of-address workflows under the Travel Rule tag
  (`/v1/screening/travel_rule`).
  """

  import FireblocksSdk.Request

  @base_path "/v1/screening/travel_rule"

  # ---------------------------------------------------------------------------
  # validate_travel_rule_transaction  (deprecated)
  # ---------------------------------------------------------------------------

  @validate_travel_rule_transaction_schema [
    transactionAsset: [
      type: :string,
      required: true,
      doc: "Asset ticker for the transaction, e.g. `\"BTC\"`, `\"ETH\"`"
    ],
    destination: [
      type: :string,
      required: true,
      doc: "Destination address of the transaction"
    ],
    transactionAmount: [
      type: :string,
      required: true,
      doc: "Amount of the transaction expressed in the transaction asset"
    ],
    originatorVASPdid: [
      type: :string,
      required: true,
      doc: "DID of the originating VASP"
    ],
    originatorEqualsBeneficiary: [
      type: :boolean,
      required: true,
      doc: "`true` when the originator and beneficiary are the same natural person"
    ],
    transactionAssetDecimals: [
      type: :non_neg_integer,
      doc: "Number of decimals for the asset"
    ],
    travelRuleBehavior: [
      type: :boolean,
      doc:
        "When `true`, checks whether the transaction is compliant with the beneficiary VASP's jurisdiction"
    ],
    beneficiaryVASPdid: [type: :string, doc: "DID of the beneficiary VASP"],
    beneficiaryVASPname: [type: :string, doc: "Name of the beneficiary VASP"],
    beneficiaryName: [type: :string, doc: "Full name of the beneficiary"],
    beneficiaryAccountNumber: [type: :string, doc: "Account number of the beneficiary"],
    beneficiaryAddress: [type: :map, doc: "TravelRuleAddress object for the beneficiary"]
  ]

  @doc """
  Validates a Travel Rule transaction (basic form).

  Checks basic Travel Rule fields for a transaction against the Notabene network.
  This endpoint is deprecated — use `validate_full_travel_rule_transaction/2`
  for full IVMS101-compliant validation instead.

  Options:\n#{NimbleOptions.docs(@validate_travel_rule_transaction_schema)}
  """
  @deprecated "Use validate_full_travel_rule_transaction/2 instead."
  @spec validate_travel_rule_transaction(keyword(), String.t()) :: map()
  def validate_travel_rule_transaction(params, idempotency_key \\ "") do
    {:ok, options} = NimbleOptions.validate(params, @validate_travel_rule_transaction_schema)
    data = options |> Enum.into(%{}) |> Jason.encode!()
    post!("#{@base_path}/transaction/validate", data, idempotency_key)
  end

  # ---------------------------------------------------------------------------
  # validate_full_travel_rule_transaction
  # ---------------------------------------------------------------------------

  @validate_full_travel_rule_transaction_schema [
    originator: [
      type: :map,
      required: true,
      doc: "Originator PII in IVMS101 format"
    ],
    beneficiary: [
      type: :map,
      required: true,
      doc: "Beneficiary PII in IVMS101 format"
    ],
    originatorVASPdid: [type: :string, doc: "DID of the originating VASP"],
    beneficiaryVASPdid: [type: :string, doc: "DID of the beneficiary VASP"],
    transactionAsset: [type: :string, doc: "Asset ticker, e.g. `\"BTC\"`, `\"ETH\"`"],
    transactionAmount: [type: :string, doc: "Amount of the transaction"],
    originatorVASPname: [type: :string, doc: "Name of the originating VASP"],
    beneficiaryVASPname: [type: :string, doc: "Name of the beneficiary VASP"],
    transactionBlockchainInfo: [type: :map, doc: "Blockchain-level transaction metadata"],
    encrypted: [type: :string, doc: "Encrypted PII payload"],
    protocol: [
      type: {:in, ["TRLight", "TRP", "OpenVASP", "GTR"]},
      doc:
        "Travel Rule protocol to use. One of `\"TRLight\"`, `\"TRP\"`, `\"OpenVASP\"`, `\"GTR\"`"
    ],
    skipBeneficiaryDataValidation: [
      type: :boolean,
      doc: "When `true`, skips server-side validation of the beneficiary data"
    ],
    travelRuleBehavior: [
      type: :boolean,
      doc:
        "When `true`, checks whether the transaction is compliant with the beneficiary VASP's jurisdiction"
    ],
    originatorRef: [type: :string, doc: "Reference ID for the originator"],
    beneficiaryRef: [type: :string, doc: "Reference ID for the beneficiary"],
    travelRuleBehaviorRef: [type: :string, doc: "Reference ID for travel rule behavior"],
    originatorProof: [type: :map, doc: "Proof object for the originator"],
    beneficiaryProof: [type: :map, doc: "Proof object for the beneficiary"],
    beneficiaryDid: [type: :string, doc: "DID of the beneficiary"],
    originatorDid: [type: :string, doc: "DID of the originator"],
    isNonCustodial: [
      type: :boolean,
      doc: "When `true`, indicates this is a non-custodial transfer"
    ],
    notificationEmail: [type: :string, doc: "Email address to receive Travel Rule notifications"],
    pii: [type: :map, doc: "Plain-text PII payload in IVMS101 format"],
    pii_url: [type: :string, doc: "URL pointing to the encrypted PII payload"]
  ]

  @doc """
  Validates a full Travel Rule transaction with IVMS101 PII.

  This is the preferred endpoint for Travel Rule compliance validation.
  Accepts complete originator and beneficiary PII in IVMS101 format and checks
  compliance against the applicable regulatory framework and the beneficiary
  VASP's jurisdiction policy.

  - `idempotency_key`: Optional idempotency key (`Idempotency-Key` header).

  Options:\n#{NimbleOptions.docs(@validate_full_travel_rule_transaction_schema)}
  """
  @spec validate_full_travel_rule_transaction(keyword(), String.t()) :: map()
  def validate_full_travel_rule_transaction(params, idempotency_key \\ "") do
    {:ok, options} =
      NimbleOptions.validate(params, @validate_full_travel_rule_transaction_schema)

    data = options |> Enum.into(%{}) |> Jason.encode!()
    post!("#{@base_path}/transaction/validate/full", data, idempotency_key)
  end

  # ---------------------------------------------------------------------------
  # get_vasp_by_did
  # ---------------------------------------------------------------------------

  @get_vasp_by_did_schema [
    fields: [
      type: :string,
      doc:
        "Comma-separated list of VASP fields to include in the response, e.g. `\"name,did,complianceLevel\"`"
    ]
  ]

  @doc """
  Returns information about a specific VASP identified by its DID.

  - `did`: The Decentralized Identifier (DID) of the VASP to retrieve.

  Options:\n#{NimbleOptions.docs(@get_vasp_by_did_schema)}
  """
  @spec get_vasp_by_did(String.t(), keyword()) :: map()
  def get_vasp_by_did(did, opts \\ []) when is_binary(did) do
    {:ok, params} = NimbleOptions.validate(opts, @get_vasp_by_did_schema)
    query_string = URI.encode_query(params)
    get!("#{@base_path}/vasp/#{did}?#{query_string}")
  end

  # ---------------------------------------------------------------------------
  # get_vasps
  # ---------------------------------------------------------------------------

  @get_vasps_schema [
    order: [
      type: {:in, ["ASC", "DESC"]},
      doc: "Sort order for results. One of `\"ASC\"` or `\"DESC\"`"
    ],
    pageSize: [
      type: :non_neg_integer,
      doc: "Number of results per page (default 500, accepted range 100–1000)"
    ],
    fields: [
      type: :string,
      doc: "Comma-separated list of VASP fields to include in each result, e.g. `\"name,did\"`"
    ],
    search: [
      type: :string,
      doc: "Free-text search query to filter VASPs by name or DID, e.g. `\"Fireblocks\"`"
    ],
    reviewValue: [
      type: {:in, ["TRUSTED", "BLOCKED", "MANUAL"]},
      doc:
        "Filter results by workspace review status. One of `\"TRUSTED\"`, `\"BLOCKED\"`, `\"MANUAL\"`"
    ],
    pageCursor: [
      type: :string,
      doc: "Opaque cursor string returned by a previous response for pagination"
    ]
  ]

  @doc """
  Returns a paginated list of VASPs from the Notabene VASP directory.

  Results default to 500 per page (accepted range 100–1000). Use the returned
  `pageCursor` to iterate through subsequent pages.

  Options:\n#{NimbleOptions.docs(@get_vasps_schema)}
  """
  @spec get_vasps(keyword()) :: map()
  def get_vasps(opts \\ []) do
    {:ok, params} = NimbleOptions.validate(opts, @get_vasps_schema)
    query_string = URI.encode_query(params)
    get!("#{@base_path}/vasp?#{query_string}")
  end

  # ---------------------------------------------------------------------------
  # update_vasp
  # ---------------------------------------------------------------------------

  @update_vasp_schema [
    did: [
      type: :string,
      required: true,
      doc: "DID of the VASP entry to update"
    ],
    pii_didkey: [
      type: :string,
      required: true,
      doc: "Public jsonDIDkey obtained from Notabene, used to encrypt PII sent to this VASP"
    ]
  ]

  @doc """
  Updates a VASP's `pii_didkey` in the workspace.

  Sets or rotates the public DID key used to encrypt PII payloads before
  transmitting them to the specified VASP.

  - `idempotency_key`: Optional idempotency key (`Idempotency-Key` header).

  Options:\n#{NimbleOptions.docs(@update_vasp_schema)}
  """
  @spec update_vasp(keyword(), String.t()) :: map()
  def update_vasp(params, idempotency_key \\ "") do
    {:ok, options} = NimbleOptions.validate(params, @update_vasp_schema)
    data = options |> Enum.into(%{}) |> Jason.encode!()
    put!("#{@base_path}/vasp/update", data, idempotency_key)
  end

  # ---------------------------------------------------------------------------
  # get_vasp_for_vault
  # ---------------------------------------------------------------------------

  @doc """
  Returns the VASP DID assigned to the vault, or an empty string if none is assigned.

  - `vault_account_id`: The ID of the vault account to query.
  """
  @spec get_vasp_for_vault(String.t()) :: map()
  def get_vasp_for_vault(vault_account_id) when is_binary(vault_account_id) do
    get!("#{@base_path}/vault/#{vault_account_id}/vasp")
  end

  # ---------------------------------------------------------------------------
  # set_vasp_for_vault
  # ---------------------------------------------------------------------------

  @set_vasp_for_vault_schema [
    vaspDid: [
      type: :string,
      doc:
        "VASP DID to assign to the vault account. Pass an empty string `\"\"` to remove an existing assignment."
    ]
  ]

  @doc """
  Assigns or removes the VASP DID for a vault account.

  Use this to link a vault to a specific VASP for Travel Rule purposes.
  Pass `vaspDid: ""` to clear an existing assignment.

  - `vault_account_id`: The ID of the vault account to configure.
  - `idempotency_key`: Optional idempotency key (`Idempotency-Key` header).

  Options:\n#{NimbleOptions.docs(@set_vasp_for_vault_schema)}
  """
  @spec set_vasp_for_vault(String.t(), keyword(), String.t()) :: map()
  def set_vasp_for_vault(vault_account_id, params, idempotency_key \\ "")
      when is_binary(vault_account_id) do
    {:ok, options} = NimbleOptions.validate(params, @set_vasp_for_vault_schema)
    data = options |> Enum.into(%{}) |> Jason.encode!()
    post!("#{@base_path}/vault/#{vault_account_id}/vasp", data, idempotency_key)
  end

  # ---------------------------------------------------------------------------
  # create_trust_proof_of_address
  # ---------------------------------------------------------------------------

  @create_trust_proof_of_address_schema [
    vaultAccountId: [
      type: :string,
      required: true,
      doc: "The vault account ID whose address will be proved"
    ],
    asset: [
      type: :string,
      required: true,
      doc: "Asset identifier for the address being proved, e.g. `\"BTC\"`, `\"ETH\"`"
    ],
    prefix: [
      type: :string,
      required: true,
      doc: "Prefix prepended to the message before signing, as required by TRUST"
    ],
    trustUuid: [
      type: :string,
      required: true,
      doc: "UUID obtained from the TRUST network via the CreateAddressOwnership flow"
    ]
  ]

  @doc """
  Creates a TRUST-compatible proof-of-address signature for a vault account.

  Generates an encoded signature by signing a TRUST-formatted message with the
  private key held in the specified vault account. The resulting signature should
  be submitted directly to the TRUST network for address-ownership verification.

  - `idempotency_key`: Optional idempotency key (`Idempotency-Key` header).

  Options:\n#{NimbleOptions.docs(@create_trust_proof_of_address_schema)}
  """
  @spec create_trust_proof_of_address(keyword(), String.t()) :: map()
  def create_trust_proof_of_address(params, idempotency_key \\ "") do
    {:ok, options} = NimbleOptions.validate(params, @create_trust_proof_of_address_schema)
    data = options |> Enum.into(%{}) |> Jason.encode!()
    post!("#{@base_path}/providers/trust/proof_of_address", data, idempotency_key)
  end

  # ---------------------------------------------------------------------------
  # get_trust_proof_of_address
  # ---------------------------------------------------------------------------

  @doc """
  Retrieves the TRUST-compatible encoded signature for proof of address.

  Send this directly to TRUST for verification.

  - `transaction_id`: The transaction ID associated with the proof-of-address request.
  """
  @spec get_trust_proof_of_address(String.t()) :: map()
  def get_trust_proof_of_address(transaction_id) when is_binary(transaction_id) do
    get!("#{@base_path}/providers/trust/proof_of_address/#{transaction_id}")
  end
end
