address SwapAdmin {

module VESTAR {
    use StarcoinFramework::Token;
    use StarcoinFramework::Signer;

    /// VESTAR token marker.
    struct VESTAR has copy, drop, store {}

    /// precision of VESTAR token.
    const PRECISION: u8 = 9;

    const ERROR_NOT_GENESIS_ACCOUNT: u64 = 10001;

    /// Returns true if `TokenType` is `VESTAR::VESTAR`
    public fun is_vestar<TokenType: store>(): bool {
        Token::is_same_token<VESTAR, TokenType>()
    }

    public fun assert_genesis_address(account: &signer) {
        assert!(Signer::address_of(account) == token_address(), ERROR_NOT_GENESIS_ACCOUNT);
    }

    /// Return VESTAR token address.
    public fun token_address(): address {
        Token::token_address<VESTAR>()
    }

    /// Return VESTAR precision.
    public fun precision(): u8 {
        PRECISION
    }
}
}