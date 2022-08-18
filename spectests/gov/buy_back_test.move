//# init -n test --public-keys SwapAdmin=0x5510ddb2f172834db92842b0b640db08c2bc3cd986def00229045d78cc528ac5 --public-keys BuyBackAccount=0x760670dd3a152f7130534758d366eea7540078832e0985cde498c40c9a2b6ae3 --addresses BuyBackAccount=0xa1869437e19a33eba1b7277218af539c

//# faucet --addr alice --amount 10000000000000000

//# faucet --addr SwapAdmin --amount 10000000000000000

//# faucet --addr BuyBackAccount --amount 10000000000000000

//# block --author 0x1 --timestamp 86400000

//# publish
module BuyBackAccount::BuyBackPoolType {
    struct BuyBackPoolType has store {}
}

//# run --signers SwapAdmin
script {
    use StarcoinFramework::STC::STC;

    use SwapAdmin::TokenMock::{Self, WUSDT};
    use SwapAdmin::CommonHelper;
    use SwapAdmin::TokenSwap;

    fun init_token(signer: signer) {
        let scale_index: u8 = 9;
        TokenMock::register_token<WUSDT>(&signer, scale_index);

        CommonHelper::safe_mint<WUSDT>(&signer, CommonHelper::pow_amount<WUSDT>(100000000));

        // Register swap pair
        TokenSwap::register_swap_pair<STC, WUSDT>(&signer);

        assert!(TokenSwap::swap_pair_exists<STC, WUSDT>(), 10001);
    }
}
// check: EXECUTED


//# run --signers alice
script {
    use SwapAdmin::CommonHelper;
    use SwapAdmin::TokenMock::WUSDT;

    fun alice_accept_wusdt(signer: signer) {
        CommonHelper::safe_accept_token<WUSDT>(&signer);
    }
}

//# run --signers SwapAdmin
script {
    use SwapAdmin::TokenMock::{WUSDT};
    use SwapAdmin::CommonHelper;

    fun transfer_to_alice(signer: signer) {
        CommonHelper::transfer<WUSDT>(
            &signer,
            @alice,
            CommonHelper::pow_amount<WUSDT>(50000)
        );
    }
}
// check: EXECUTED

//# run --signers SwapAdmin
script {
    use StarcoinFramework::Account;
    use StarcoinFramework::Signer;
    use StarcoinFramework::Math;
    use StarcoinFramework::STC::STC;
    use StarcoinFramework::Debug;

    use SwapAdmin::TokenMock::{WUSDT};
    use SwapAdmin::TokenSwapRouter;
    use SwapAdmin::CommonHelper;

    fun add_liquidity_and_swap(signer: signer) {
        let precision: u8 = 9; //STC precision is also 9.
        let scaling_factor = Math::pow(10, (precision as u64));
        // STC/WUSDT = 1:5
        //let stc_amount: u128 = 10000 * scaling_factor;

        ////////////////////////////////////////////////////////////////////////////////////////////
        // Add liquidity, STC/WUSDT = 1:5
        let amount_stc_desired: u128 = 100 * scaling_factor;
        let amount_usdt_desired: u128 = 500 * scaling_factor;
        let amount_stc_min: u128 = 1 * scaling_factor;
        let amount_usdt_min: u128 = 1 * scaling_factor;

        TokenSwapRouter::add_liquidity<STC, WUSDT>(
            &signer,
            amount_stc_desired,
            amount_usdt_desired,
            amount_stc_min,
            amount_usdt_min
        );

        let total_liquidity: u128 = TokenSwapRouter::total_liquidity<STC, WUSDT>();
        assert!(total_liquidity > amount_stc_min, 10002);

        let y_out = TokenSwapRouter::compute_y_out<STC, WUSDT>(CommonHelper::pow_amount<STC>(1));
        Debug::print(&y_out);
        assert!(y_out >= CommonHelper::pow_amount<WUSDT>(4), 10003);

        let stc_balance = Account::balance<STC>(Signer::address_of(&signer));
        Debug::print(&stc_balance);
    }
}
// check: EXECUTED

//# run --signers BuyBackAccount
script {
    use StarcoinFramework::STC::STC;
    use StarcoinFramework::Debug;

    use SwapAdmin::BuyBack;
    use SwapAdmin::TokenMock::{WUSDT};
    use SwapAdmin::CommonHelper;
    use SwapAdmin::TimelyReleasePool;

    fun init_payback(signer: signer) {
        BuyBack::init_event(&signer);
        BuyBack::accept<BuyBackAccount::BuyBackPoolType::BuyBackPoolType, WUSDT, STC>(
            &signer,
            CommonHelper::pow_amount<STC>(100),
            86400,
            10,
            CommonHelper::pow_amount<STC>(1),
        );
        let (
            treasury_balance,
            total_treasury_amount,
            release_per_time,
            begin_time,
            latest_withdraw_time,
            interval,
            current_time_stamp,
            current_time_amount,
        ) = TimelyReleasePool::query_pool_info<BuyBackAccount::BuyBackPoolType::BuyBackPoolType, STC>(@BuyBackAccount);

        Debug::print(&11111111);
        Debug::print(&treasury_balance);
        Debug::print(&total_treasury_amount);
        Debug::print(&release_per_time);
        Debug::print(&begin_time);
        Debug::print(&latest_withdraw_time);
        Debug::print(&interval);
        Debug::print(&current_time_stamp);
        Debug::print(&current_time_amount);
        Debug::print(&22222222);
    }
}
// check: EXECUTED

//# block --author 0x1 --timestamp 86411000

//# run --signers alice
script {
    use StarcoinFramework::STC::STC;
    use StarcoinFramework::Account;
    use StarcoinFramework::Debug;

    use SwapAdmin::TokenMock::{WUSDT};
    use SwapAdmin::BuyBack;
    use SwapAdmin::TimelyReleasePool;

    fun do_buyback(sender: signer) {
        let (
            _,
            _,
            _,
            _,
            _,
            _,
            _,
            current_time_amount,
        ) = TimelyReleasePool::query_pool_info<BuyBackAccount::BuyBackPoolType::BuyBackPoolType, STC>(@BuyBackAccount);

        BuyBack::buy_back<BuyBackAccount::BuyBackPoolType::BuyBackPoolType, WUSDT, STC>(&sender, @BuyBackAccount);
        let sell_amount = Account::balance<WUSDT>(@BuyBackAccount);
        Debug::print(&current_time_amount);
        Debug::print(&sell_amount);
        assert!(sell_amount >= (current_time_amount * 4), 10004);
        Debug::print(&sell_amount);
    }
}
// check: EXECUTED

//# block --author 0x1 --timestamp 89410000

//# run --signers alice
script {
    use StarcoinFramework::Debug;
    use StarcoinFramework::STC;

    use SwapAdmin::TimelyReleasePool;

    fun query_buyback_information(_sender: signer) {
        let (
            treasury_balance,
            total_treasury_amount,
            release_per_time,
            begin_time,
            latest_withdraw_time,
            interval,
            current_time_stamp,
            current_time_amount,
        ) = TimelyReleasePool::query_pool_info<BuyBackAccount::BuyBackPoolType::BuyBackPoolType, STC::STC>(@BuyBackAccount);

        Debug::print(&33333333);
        Debug::print(&treasury_balance);
        Debug::print(&total_treasury_amount);
        Debug::print(&release_per_time);
        Debug::print(&begin_time);
        Debug::print(&latest_withdraw_time);
        Debug::print(&interval);
        Debug::print(&current_time_stamp);
        Debug::print(&current_time_amount);
        Debug::print(&44444444);

        assert!(current_time_amount == 99000000000, 10005);
        assert!(treasury_balance >= current_time_amount, 10006);
    }
}

//# block --author 0x1 --timestamp 289410000

//# run --signers alice
script {
    use StarcoinFramework::STC::STC;
    use StarcoinFramework::Account;
    use StarcoinFramework::Debug;

    use SwapAdmin::TokenMock::{WUSDT};
    use SwapAdmin::BuyBack;
    use SwapAdmin::TimelyReleasePool;

    fun do_buyback_again_beyond_max_release_time(sender: signer) {
        let (
            treasury_balance,
            _,
            _,
            _,
            _,
            _,
            _,
            current_time_amount,
        ) = TimelyReleasePool::query_pool_info<BuyBackAccount::BuyBackPoolType::BuyBackPoolType, STC>(@BuyBackAccount);

        BuyBack::buy_back<BuyBackAccount::BuyBackPoolType::BuyBackPoolType, WUSDT, STC>(&sender, @BuyBackAccount);
        let sell_amount_balance = Account::balance<WUSDT>(@BuyBackAccount);
        Debug::print(&treasury_balance);
        Debug::print(&sell_amount_balance);
        Debug::print(&current_time_amount);
    }
}
// check: EXECUTED


//# run --signers alice
script {
    use StarcoinFramework::STC::STC;
    //use StarcoinFramework::Account;
    use StarcoinFramework::Debug;

    //use SwapAdmin::TokenMock::{WUSDT};
    // use SwapAdmin::BuyBack;
    use SwapAdmin::TimelyReleasePool;

    fun query_after_withdraw_all(_sender: signer) {
        let (
            treasury_balance,
            _,
            _,
            _,
            _,
            _,
            _,
            current_time_amount,
        ) = TimelyReleasePool::query_pool_info<BuyBackAccount::BuyBackPoolType::BuyBackPoolType, STC>(@BuyBackAccount);

//        BuyBack::buy_back<BuyBackAccount::BuyBackPoolType::BuyBackPoolType, WUSDT, STC>(&sender, @BuyBackAccount);
//        let sell_amount_balance = Account::balance<WUSDT>(@BuyBackAccount);
        Debug::print(&treasury_balance);
        Debug::print(&current_time_amount);
    }
}
// check: EXECUTED

//# run --signers BuyBackAccount
script {
    use StarcoinFramework::STC::STC;
    use SwapAdmin::BuyBack;

    fun dismiss(sender: signer) {
        BuyBack::dismiss<BuyBackAccount::BuyBackPoolType::BuyBackPoolType, STC>(&sender);
    }
}
// check: EXECUTED
