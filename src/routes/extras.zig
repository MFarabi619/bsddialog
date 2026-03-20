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
    conf.title = "Extras: System Setup Tree";
    conf.bottomtitle = "• ←→ move • ⇥ TAB • ⏎ ENTER •";
    conf.auto_topmargin = 2;

    c.bsddialog_clear(0);
    _ = c.bsddialog_backtitle_rf(&conf, "DoomBSD Extras Configuration");

    var items = [_]c.struct_bsddialog_menuitem{
        .{ .name = "ffmpegthumbnailer", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "coreutils", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "cmake", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "poppler", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "7-zip", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "aspell", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "en-aspell", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "aspell-ispell", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "lazyvim", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "doom emacs", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "procs", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "btop", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "fastfetch", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "lazygit", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "zellij", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "markdown", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "markdown-fmt", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "npm", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "docker", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "docker-compose", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "k9s", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "cmatrix", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "cowsay", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "asciiquarium", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "figlet", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "lolcat", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "nyancat", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
        .{ .name = "rgb-tui", .desc = "", .on = false, .depth = 0, .prefix = "", .bottomdesc = "" },
    };

    const output = c.bsddialog_checklist(
        &conf,
        "Select optional setup steps:",
        0,
        0,
        15,
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
