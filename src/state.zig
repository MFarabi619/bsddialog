pub const State = enum {
    main_menu,
    the_summoning_ritual,
    extras,
    lore,
    seek_help,
    health,
    exit,
};

pub fn routeFromMenuChoice(choice: u8) ?State {
    return switch (choice) {
        'D' => .the_summoning_ritual,
        'X' => .extras,
        'L' => .lore,
        '?' => .seek_help,
        'H' => .health,
        else => null,
    };
}
