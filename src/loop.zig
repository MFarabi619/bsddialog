const std = @import("std");
const state_mod = @import("state.zig");

const main_menu = @import("routes/main_menu.zig");
const the_summoning_ritual = @import("routes/the_summoning_ritual.zig");
const extras = @import("routes/extras.zig");
const lore = @import("routes/lore.zig");
const seek_help = @import("routes/seek_help.zig");
const health = @import("routes/health.zig");
const messages = @import("routes/messages.zig");

const c = @import("c/bindings.zig").c;

pub fn run() !void {
    var state: state_mod.State = .main_menu;
    var selected_buf: [4096]u8 = undefined;

    while (state != .exit) {
        switch (state) {
            .main_menu => {
                const menu_result = try main_menu.run();

                switch (menu_result.output) {
                    c.BSDDIALOG_OK => {},
                    c.BSDDIALOG_CANCEL => {
                        try messages.show(.{
                            .text = "Cowardice detected. Fleeing the void...",
                            .rows = 6,
                            .cols = 50,
                        });
                        state = .exit;
                        continue;
                    },
                    c.BSDDIALOG_HELP, c.BSDDIALOG_EXTRA => {
                        try messages.show(.{
                            .text = "You take a moment to collect yourself... but the ritual remains unfinished.",
                            .rows = 6,
                            .cols = 50,
                        });
                        state = .main_menu;
                        continue;
                    },
                    else => {
                        try messages.show(.{
                            .text = "Unknown signal. The abyss stirs...",
                            .rows = 6,
                            .cols = 50,
                        });
                        state = .main_menu;
                        continue;
                    },
                }

                if (menu_result.choice) |choice| {
                    if (state_mod.routeFromMenuChoice(choice)) |next| {
                        state = next;
                    } else {
                        try messages.show(.{
                            .text = "The Void does not recognize this path...",
                            .rows = 6,
                            .cols = 50,
                        });
                        state = .main_menu;
                    }
                } else {
                    try messages.show(.{
                        .text = "The Void does not recognize this path...",
                        .rows = 6,
                        .cols = 50,
                    });
                    state = .main_menu;
                }
            },
            .the_summoning_ritual => {
                const result = try the_summoning_ritual.run(selected_buf[0..]);

                if (result.output == c.BSDDIALOG_OK) {
                    const msg_tmp = try std.fmt.allocPrint(std.heap.c_allocator, "You chose to configure:\n\n{s}\n\nLet the rite begin...", .{result.selected});
                    defer std.heap.c_allocator.free(msg_tmp);
                    const msg = try std.heap.c_allocator.dupeZ(u8, msg_tmp);
                    defer std.heap.c_allocator.free(msg);

                    try messages.show(.{ .text = msg, .rows = 12, .cols = 60 });
                } else {
                    try messages.show(.{
                        .text = "You fled the chamber. No changes made to your fate.",
                        .rows = 6,
                        .cols = 60,
                    });
                }

                state = .main_menu;
            },
            .extras => {
                const result = try extras.run(selected_buf[0..]);

                if (result.output == c.BSDDIALOG_OK) {
                    const msg_tmp = try std.fmt.allocPrint(std.heap.c_allocator, "You selected:\n{s}", .{result.selected});
                    defer std.heap.c_allocator.free(msg_tmp);
                    const msg = try std.heap.c_allocator.dupeZ(u8, msg_tmp);
                    defer std.heap.c_allocator.free(msg);

                    try messages.show(.{ .text = msg, .rows = 10, .cols = 60 });
                } else {
                    try messages.show(.{
                        .text = "No extras selected. The void remains untouched.",
                        .rows = 6,
                        .cols = 60,
                    });
                }

                state = .main_menu;
            },
            .lore => {
                try lore.run();
                state = .main_menu;
            },
            .seek_help => {
                try seek_help.run();
                state = .main_menu;
            },
            .health => {
                try health.run();
                state = .main_menu;
            },
            .exit => unreachable,
        }
    }
}
