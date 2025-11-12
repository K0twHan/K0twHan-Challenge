module challenge::arena;

use challenge::hero::Hero;
use sui::event;

// ========= STRUCTS =========

public struct Arena has key, store {
    id: UID,
    warrior: Hero,
    owner: address,
}

// ========= EVENTS =========

public struct ArenaCreated has copy, drop {
    arena_id: ID,
    timestamp: u64,
}

public struct ArenaCompleted has copy, drop {
    winner_hero_id: ID,
    loser_hero_id: ID,
    timestamp: u64,
}

// ========= FUNCTIONS =========

public fun create_arena(hero: Hero, ctx: &mut TxContext) {
    let arena = Arena {
        id: object::new(ctx),
        warrior: hero,
        owner: ctx.sender(),
    };
    event::emit(ArenaCreated {
        arena_id: object::id(&arena),
        timestamp: ctx.epoch_timestamp_ms(),
    });
    transfer::share_object(arena);

    // TODO: Create an arena object
    // Hints:
    // Use object::new(ctx) for unique ID
    // Set warrior field to the hero parameter
    // Set owner to ctx.sender()
    // TODO: Emit ArenaCreated event with arena ID and timestamp (Don't forget to use ctx.epoch_timestamp_ms(), object::id(&arena))
    // TODO: Use transfer::share_object() to make it publicly tradeable
}

#[allow(lint(self_transfer))]
public fun battle(hero: Hero, arena: Arena, ctx: &mut TxContext) {
    let Arena { id: arena_id, warrior, owner: _owner } = arena;
    object::delete(arena_id);
    let winner: Hero;
    let loser: Hero;
    if (hero.hero_power() > warrior.hero_power()) {
        winner = hero;
        loser = warrior;
    } else {
        winner = warrior;
        loser = hero;
    };
    event::emit(ArenaCompleted {
        winner_hero_id: object::id(&winner),
        loser_hero_id: object::id(&loser),
        timestamp: ctx.epoch_timestamp_ms(),
    });

    transfer::public_transfer(winner, ctx.sender());
    transfer::public_transfer(loser, ctx.sender());
}
