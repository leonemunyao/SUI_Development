module SuiMetaverseLand::SuiMetaverseLand {

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
    use SuiMetaverseLand::eth::ETH;
    use SuiMetaverseLand::usdc::USDC;


    // constants
    const CLIENT_ID: u64 = 122227;
    const MAX_U64: u64 = 18446744073709551615;
    const NO_RESTRICTION: u64 = 0;
    const FLOAT_SCALING: u64 = 1_000_000_000;
    const EAlreadyMintedThisEpoch: u64 = 0;


    struct SuiMetaverseLand has drop {}

    struct Data<phantom CoinType> has store {
        cap: TreasuryCap<CoinType>,
        faucet_lock: Table<address, u64>,
    }

    struct Storage has key {
        id: UID,
        land_supply: Supply<SuiMetaverseLand>,
        swap: Table<address, u64>,
        account_cap: AccountCap,
        client_id: u64,
    }

    #[allow(unused_function)]
    fun init(witness: SuiMetaverseLand, ctx: &mut TxContext) {
        let (treasuary_cap, metadata) = coin::create_currency<SuiMetaverseLand>(
            witness,
            9,
            b"SuiMetaverseLand",
            b"SuiMetaverseLand Coin",
            b"Coin of SuiMetaverseLand",
            option::none(),
            ctx,
        );

        transfer::public_freeze_object(metadata);

        transfer::share_object(Storage {
            id: object::new(ctx),
            land_supply: coin::treasury_into_supply(treasuary_cap),
            transfers: table::new(ctx),
            account_cap: clob::create_account(ctx),
            client_id: CLIENT_ID,
        });
    }

    public fun user_land_transfer_epoch<CoinType>(self: &Storage, user: address): u64 {
        let data = df::borrow<TypeName, Data<CoinType>>(&self.id, get<CoinType>());

        if (table::contains(data.faucet_lock, user)) return *table::get(data.faucet_lock, user);

        0
    }

    public fun user_transfer_count(self: &Storage, user: address): u64 {
        if (table::contains(self.transfers, user)) return *table::borrow(self.transfers, user);

        0
    }

    public fun entry_create_rental_agreement(
        self: &mut Storage,
        pool: &mut Pool<ETH, USDC>,
        account_cap: &AccountCap,
        quantity: u64,
        is_bid: bool,
        base:coin: Coin<ETH>,
        quote:coin: Coin<USDC>,
        c: &Clock,
        ctx: &mut TxContext,
    ) {
        let (eth, usdc, coin_dex) = create_rental_agreement(self, pool, account_cap, quantity, is_bid, base_coin, quote_coin, c, ctx);
        let sender = tx_context::sender(ctx);
        transfer_coin(eth, sender);
        transfer_coin(usdc, sender);
        transfer_coin(coin_dex, sender);
    }


    public fun create_rental_agreement(
        self: &mut Storage,
        pool: &mut Pool<ETH, USDC>,
        account_cap: &AccountCap,
        quantity: u64,
        is_bid: bool,
        base_coin: Coin<ETH>,
        quote_coin: Coin<USDC>,
        c: &Clock,
        ctx: &mut TxContext,
    ): (Coin<ETH>, Coin<USDC>, Coin<SuiMetaverseLand>) {
        let sender = tx_context::sender(ctx);
        let client_order_id = 0;
        let dex_coin = coin::zero(ctx);


    if (table::contains(&self.transfers, sender)) {
        let total_transfers = table::borrow_mut(&mut self.transfers, sender);
        let new_total_transfers = *total_transfers + 1; 
        *total_transfers = new_total_transfers; 
        client_order_id = new_total_transfers;

        if ((new_total_transfers % 2) == 0) {
            coin::join(&mut sml_coin, coin::from_balance(balance::increase_supply(&mut self.lamd_supply, FLOAT_SCALING, ctx)));
        };
    } else {
        table::add(&mut self.transfers, sender, 1);
    };

    let (eth_coin, usdc_coin) = clob::create_rental_agreement(
        pool,
        account_cap,
        client_order_id,
        quantity,
        is_bid,
        base_coin,
        quote_coin,
        c,
        ctx
        );

        (eth_coin, usdc_coin, dex_coin)

    }

    public fun create_land_pull(fee: Coin<SUI>, ctx: &mut TxContext) {
        clob::create_land_pull<ETH, USDC>(1 * FLOAT_SCALING, 1, fee, ctx);
    }

    public fun fill_land_pull(
        self: &mut Storage,
        pool: &mut Pool<ETH, USDC>,
        c: &Clock,
        ctx: &mut TxContext,
    ) {
        create_land_ask_orders(self, pool, c, ctx);
        create_land_bid_orders(self, pool, c, ctx);
    }

    public fun create_land_state(
        self: &mut Storage,
        eth_cap: TreasuryCap<ETH>,
        usdc_cap: TreasuryCap<USDC>,
        ctx: &mut TxContext,
    ) {
        df::add(&mut self.id, get<ETH>(), Data {cap: eth_cap, faucet_lock: table::new(ctx)});
        df::add(&mut self.id, get<USDC>(), Data {cap: usdc_cap, faucet_lock: table::new(ctx)});
    }

    
    public fun mint_land_token<CoinType>(self: &mut Storage, ctx: &mut TxContext): Coin<CoinType> {
        let sender = tx_context::sender(ctx);
        let current_epoch = tx_content::epoch(ctx);
    }

}