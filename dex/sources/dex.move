module dex::dex {

    // Necessary imports
    use std::option;
    use std::type_name::{get, TypeName};
    use sui::transfer;
    use sui::sui::SUI;
    use sui::clock::{clock};
    use sui::balance::{Self, Supply};
    use sui::object::{Self, UID};
    use sui::table::{Self, Table};
    use sui::dynamic_field as df;
    use sui::tx_context::{Self, TxContext};
    use sui::coin::{Self, TreasuryCap, Coin};
    use deepbook::custodian_v2::AccountCap;
    use deepbook::clob_v2::{Self as clob, Pool};
    use dex::eth::ETH;
    use dex::usdc::USDC;


    // constants
    const CLIENT_ID: u64 = 122227;
    const MAX_U64: u64 = 18446744073709551615;
    const NO_RESTRICTION: u64 = 0;
    const FLOAT_SCALING: u64 = 1_000_000_000;
    const EAlreadyMintedThisEpoch: u64 = 0;


    struct dex has drop {}

    struct Data<phantom CoinType> has store {
        cap: TreasuryCap<CoinType>,
        faucet_lock: Table<address, u64>,
    }

    struct Storage has key {
        id: UID,
        dex_supply: Supply<DEX>,
        swap: Table<address, u64>,
        account_cap: AccountCap,
        client_id: u64,
    }

    


}