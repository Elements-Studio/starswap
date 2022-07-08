//# init -n test --public-keys SwapAdmin=0x5510ddb2f172834db92842b0b640db08c2bc3cd986def00229045d78cc528ac5

//# faucet --addr alice --amount 10000000000000000

//# faucet --addr SwapAdmin --amount 10000000000000000

//# block --author 0x1 --timestamp 10000000


//# run --signers SwapAdmin
script{
    use StarcoinFramework::StdlibUpgradeScripts;

    fun main(){
        StdlibUpgradeScripts::upgrade_from_v11_to_v12();
    }
}

//# run --signers alice
script {
    use StarcoinFramework::GenesisDao;

    use SwapAdmin::StarswapDao;

    fun check_is_member() {
        assert!(!GenesisDao::is_member<StarswapDao::StarswapDao>(@alice), 10001);
    }
}
// check: EXECUTED

//# run --signers SwapAdmin
script {
    use StarcoinFramework::DaoAccount;

    fun admin_create_dao(signer: signer) {
        DaoAccount::create_account_entry(signer);
    }
}
// check: EXECUTED


//# run --signers SwapAdmin
script {
    use SwapAdmin::StarswapDao;

    fun admin_create_dao(signer: signer) {
        StarswapDao::create_dao(signer, 10, 10, 10, 10, 10);
    }
}
// check: EXECUTED


//# run --signers alice
script {
    use StarcoinFramework::GenesisDao;

    use SwapAdmin::StarswapDao;
    use SwapAdmin::VestarPlugin;

    fun check_is_member(signer: signer) {
        assert!(!GenesisDao::is_member<StarswapDao::StarswapDao>(@alice), 10001);

        VestarPlugin::accept_sbt<StarswapDao::StarswapDao>(&signer);
        VestarPlugin::join_member<StarswapDao::StarswapDao>(@alice);

        assert!(GenesisDao::is_member<StarswapDao::StarswapDao>(@alice), 10002);
    }
}
// check: EXECUTED
