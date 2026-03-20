const std = @import("std");
const messages = @import("messages.zig");

const c = @import("../c/bindings.zig").c;
const session = @import("../bsddialog/session.zig");

pub const Result = struct {
    output: c_int,
    selected: []const u8,
};

pub fn run(selected_buf: []u8) !Result {
    var conf: c.struct_bsddialog_conf = undefined;
    messages.initCliLikeConf(&conf);
    conf.title = " The Summoning Ritual";
    conf.bottomtitle = "• ←→ move • ⇥ TAB • ⏎ ENTER •";
    conf.auto_topmargin = 2;

    c.bsddialog_clear(0);
    _ = c.bsddialog_backtitle_rf(&conf, "DoomBSD Catacombs");

    var items = [_]c.struct_bsddialog_menuitem{
        .{ .name = "ui", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "hyprland (HyDE)", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "dbus", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "xdg-desktop-portal", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "wayland", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "xwayland", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "editor", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "neovim", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "py311-pynvim", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "emacs", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "git", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "jetbrains-mono", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "nerd-fonts", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "noto-emoji", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "term", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "vips", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "direnv", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "yazi", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "bash", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "zsh", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "tree", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "eza", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "fzf", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "ripgrep", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "ripgrep-all", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "bat", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "app", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "arduino", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "yt-dlp", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "unzip", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "icu", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "vlc", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
    };

    const output = c.bsddialog_checklist(
        &conf,
        "Here in the chamber, unseen daemons stir beneath the surface... shaping the destiny of your system.",
        0,
        0,
        18,
        items.len,
        &items,
        null,
    );
    if (output == c.BSDDIALOG_ERROR) {
        std.debug.print("Error: {s}\n", .{session.getError()});
        return error.BSDDialogChecklistFailed;
    }

    if (output != c.BSDDIALOG_OK) {
        return .{ .output = output, .selected = "" };
    }

    const selected = try serializeChecklistSelections(items[0..], selected_buf);
    return .{ .output = output, .selected = selected };
}

fn serializeChecklistSelections(items: []const c.struct_bsddialog_menuitem, buf: []u8) ![]const u8 {
    var fbs = std.io.fixedBufferStream(buf);
    const w = fbs.writer();

    var first = true;
    for (items) |item| {
        if (!item.on) continue;

        const name = std.mem.span(item.name);
        if (!first) {
            try w.writeByte(' ');
        }
        first = false;

        const has_space = std.mem.indexOfScalar(u8, name, ' ') != null;
        if (has_space) {
            try w.writeByte('"');
        }
        try w.writeAll(name);
        if (has_space) {
            try w.writeByte('"');
        }
    }

    return fbs.getWritten();
}
