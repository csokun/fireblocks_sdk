import Config

config :fireblocks_sdk,
  # The following private key is borrowed from Joken example https://hexdocs.pm/joken/signers.html#pem-privacy-enhanced-mail
  # so you can test FireblocksSdk.Signer.sign_jwt/2 
  apiSecret: """
  -----BEGIN PRIVATE KEY-----
  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
  8O2+LTOry+T0HO7FL2BR8ltr6k4MKYLg
  -----END PRIVATE KEY-----"
  """
