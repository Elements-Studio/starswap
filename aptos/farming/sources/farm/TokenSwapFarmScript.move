// Copyright (c) The Elements Studio Core Contributors
// SPDX-License-Identifier: Apache-2.0

module SwapAdmin::TokenSwapFarmScript {
    use SwapAdmin::TokenSwapFarmRouter;
    use SwapAdmin::TokenSwapFarmBoost;

    /// Called by admin account
    public entry fun add_farm_pool<X: copy + drop + store, Y: copy + drop + store>(account: &signer, release_per_second: u128) {
        TokenSwapFarmRouter::add_farm_pool<X, Y>(account, release_per_second);
    }

    /// Called by admin account
    public entry fun add_farm_pool_v2<X: copy + drop + store, Y: copy + drop + store>(account: &signer, alloc_point: u128) {
        TokenSwapFarmRouter::add_farm_pool_v2<X, Y>(account, alloc_point);
    }

    public entry fun reset_farm_activation<X: copy + drop + store, Y: copy + drop + store>(account: &signer, active: bool) {
        TokenSwapFarmRouter::reset_farm_activation<X, Y>(account, active);
    }

    /// Stake liquidity token
    public entry fun stake<X: copy + drop + store, Y: copy + drop + store>(account: &signer, amount: u128) {
        TokenSwapFarmRouter::stake<X, Y>(account, amount);
    }

    /// Unstake liquidity token
    public entry fun unstake<X: copy + drop + store, Y: copy + drop + store>(account: &signer, amount: u128) {
        TokenSwapFarmRouter::unstake<X, Y>(account, amount);
    }

    /// Havest governance token from pool
    public entry fun harvest<X: copy + drop + store, Y: copy + drop + store>(account: &signer, amount: u128) {
        TokenSwapFarmRouter::harvest<X, Y>(account, amount);
    }

    /// Get gain count
    public fun lookup_gain<X: copy + drop + store, Y: copy + drop + store>(account: address): u128 {
        TokenSwapFarmRouter::lookup_gain<X, Y>(account)
    }

    /// Query an info from farm which combinded X and Y
    public fun query_info<X: copy + drop + store, Y: copy + drop + store>(): (bool, u128, u128, u128) {
        TokenSwapFarmRouter::query_info<X, Y>()
    }

    /// Query all stake amount
    public fun query_total_stake<X: copy + drop + store, Y: copy + drop + store>(): u128 {
        TokenSwapFarmRouter::query_total_stake<X, Y>()
    }

    /// Query all stake amount
    public fun query_stake<X: copy + drop + store, Y: copy + drop + store>(account: address): u128 {
        TokenSwapFarmRouter::query_stake<X, Y>(account)
    }

    /// Query release per second
    public fun query_release_per_second<X: copy + drop + store, Y: copy + drop + store>(): u128 {
        TokenSwapFarmRouter::query_release_per_second<X, Y>()
    }

    public entry fun set_farm_multiplier<X: copy + drop + store, Y: copy + drop + store>(signer: &signer, mutiple: u64) {
        TokenSwapFarmRouter::set_farm_multiplier<X, Y>(signer, mutiple);
    }

    public entry fun set_farm_alloc_point<X: copy + drop + store, Y: copy + drop + store>(signer: &signer, alloc_point: u128) {
        TokenSwapFarmRouter::set_farm_alloc_point<X, Y>(signer, alloc_point);
    }

    public fun get_farm_multiplier<X: copy + drop + store, Y: copy + drop + store>(): u64 {
        TokenSwapFarmRouter::get_farm_multiplier<X, Y>()
    }

    /// boost for farm
    public entry fun boost<X: copy + drop + store, Y: copy + drop + store>(signer: &signer, boost_amount: u128) {
        TokenSwapFarmRouter::boost<X, Y>(signer, boost_amount);
    }
           
    /// white list boost for farm
    public entry fun wl_boost<X: copy + drop + store, Y: copy + drop + store>(signer: &signer, boost_amount: u128,signature:vector<u8>) {
        TokenSwapFarmRouter::wl_boost<X, Y>(signer, boost_amount,&signature);
    }

    public entry fun initialize_boost_event(signer: &signer){
       TokenSwapFarmBoost::initialize_boost_event(signer);
    }
}