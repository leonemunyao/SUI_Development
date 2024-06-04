use std::option;
use sui::url;
use sui::transfer;
use sui::coin;
use sui::tx_context::{Self, TxContext};

struct ETH has drop {}


// This is the initialization function init defined. Takes a witness OF type ETH and mutable context to TxContext.  

fun init(witness: ETH, ctx: &mut TxContext) {
    let (treasury_cap, metadata) = coin::create_currency<ETH>( //Create the new currency (ETH coin).
        witness,
        9,
        b"ETH",
        b"ETH Coin",
        b"Ethereum Native Coin",
        option::some(url::new_unsafe_from_bytes(b"https://s2.coinmarketcap.com/static/img/coins/64x64/1027.png")),
        ctx
    );

    transfer::public_transfer(treasury_cap, tx_context::sender(ctx)); // The treasury capability and metadata obtained from the 
    // create_currency are then used to transfer the treasury capability to the deployer(transfer::public_transfer) and share the metadata
    // with the public(transfer::public_share_object).

    transfer::public_share_object(metadata);
}


#[test_only]
public fun init_for_testing(ctx: &mut TxContext) {
    let witness = ETH {};
    init(witness, ctx);
}