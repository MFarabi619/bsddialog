const std = @import("std");
const doombsd = @import("doombsd");

const c = doombsd.c;

pub fn main() !void {
    doombsd.session.setLocale();
    try doombsd.session.init();
    defer doombsd.session.end();

    try applyDoomTheme();
    try runInstallerLoop();
}

fn runInstallerLoop() !void {
    while (true) {
        const menu_result = try showMainMenu();

        switch (menu_result.output) {
            c.BSDDIALOG_OK => {},
            c.BSDDIALOG_CANCEL => {
                try showMsgBox(.{
                    .text = "Cowardice detected. Fleeing the void...",
                    .rows = 6,
                    .cols = 50,
                });
                return;
            },
            c.BSDDIALOG_HELP, c.BSDDIALOG_EXTRA => {
                try showMsgBox(.{
                    .text = "You take a moment to collect yourself... but the ritual remains unfinished.",
                    .rows = 6,
                    .cols = 50,
                });
                continue;
            },
            else => {
                try showMsgBox(.{
                    .text = "Unknown signal. The abyss stirs...",
                    .rows = 6,
                    .cols = 50,
                });
                continue;
            },
        }

        if (menu_result.choice == null) {
            try showMsgBox(.{
                .text = "The Void does not recognize this path...",
                .rows = 6,
                .cols = 50,
            });
            continue;
        }

        switch (menu_result.choice.?) {
            'D' => try runSummoningChecklist(),
            'X' => try runExtrasChecklist(),
            'L' => try showMsgBox(.{
                .title = "📖 THE LORE",
                .text =
                    "DoomBSD draws inspiration from:\n\n"
                    ++ "- Doom Emacs by Henrik Lissner\n"
                    ++ "- HyDE Project\n"
                    ++ "- ZaneyOS\n"
                    ++ "- LazyVim\n"
                    ++ "- FreeBSD-SetupScript by es-j3\n"
                    ++ "  https://github.com/es-j3/FreeBSD-SetupScript\n\n"
                    ++ "A testament to those who dare dream deeper in dotfiles and the dark.",
                .rows = 14,
                .cols = 70,
            }),
            '?' => try showMsgBox(.{
                .title = "❓ Seek Help",
                .text =
                    "Need help?\n\n"
                    ++ "- Handbook: https://docs.freebsd.org/en/books/handbook/\n"
                    ++ "- DoomBSD Docs: No gods. No tech support. Only source code.\n"
                    ++ "- Community: Nonexistent :/",
                .rows = 12,
                .cols = 60,
            }),
            'H' => try showMsgBox(.{
                .text = "There is no help here, return from whence you came.",
                .rows = 6,
                .cols = 60,
            }),
            else => try showMsgBox(.{
                .text = "The Void does not recognize this path...",
                .rows = 6,
                .cols = 50,
            }),
        }
    }
}

const MenuResult = struct {
    output: c_int,
    choice: ?u8,
};

fn showMainMenu() !MenuResult {
    var conf: c.struct_bsddialog_conf = undefined;
    initCliLikeConf(&conf);
    conf.title = "󰇺 Main Menu";
    conf.button.ok_label = "PROCEED";
    conf.button.cancel_label = "FLEE";
    conf.button.with_help = true;
    conf.button.help_label = "HELP";
    conf.bottomtitle = "• ←→ move • ⇥ TAB • ⏎ ENTER •";
    conf.auto_topmargin = 2;

    c.bsddialog_clear(0);
    _ = c.bsddialog_backtitle_rf(&conf, " DoomBSD Catacombs");

    var items = [_]c.struct_bsddialog_menuitem{
        .{ .name = "D", .desc = " The Summoning Ritual", .bottomdesc = "Tweak existing packages used by DoomBSD.", .on = false, .depth = 0, .prefix = "" },
        .{ .name = "X", .desc = "󰏗 Extras", .bottomdesc = "Experimental features not meant for mortals. You are already who you must become.", .on = false, .depth = 0, .prefix = "" },
        .{ .name = "L", .desc = " Lore", .bottomdesc = "Credits, inspirations, and heresies.", .on = false, .depth = 0, .prefix = "" },
        .{ .name = "?", .desc = " Seek Help", .bottomdesc = "Links to guides, or whatever remains of them.", .on = false, .depth = 0, .prefix = "" },
        .{ .name = "H", .desc = "󰊢 Health", .bottomdesc = "Check your temperature, fan the flames.", .on = false, .depth = 0, .prefix = "" },
    };

    const output = c.bsddialog_menu(
        &conf,
        "Welcome traveller, you have come not seeking peace... but madness, mayhem, and the cursed power of the Void.\n\nBe warned: this path leads only to insane efficiency, terminal sorcery, exceptional UNIX grokking, and ultimate aesthetic overfunction.\n\nBegin the Rite of Configuration, ONLY IF YOU DARE!",
        0,
        0,
        8,
        items.len,
        &items,
        null,
    );
    if (output == c.BSDDIALOG_ERROR) {
        std.debug.print("Error: {s}\n", .{doombsd.session.getError()});
        return error.BSDDialogMenuFailed;
    }

    for (items) |item| {
        if (item.on) {
            const name = std.mem.span(item.name);
            if (name.len > 0) {
                return .{ .output = output, .choice = name[0] };
            }
        }
    }

    return .{ .output = output, .choice = null };
}

fn runSummoningChecklist() !void {
    var conf: c.struct_bsddialog_conf = undefined;
    initCliLikeConf(&conf);
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
        std.debug.print("Error: {s}\n", .{doombsd.session.getError()});
        return error.BSDDialogChecklistFailed;
    }

    if (output == c.BSDDIALOG_OK) {
        var selected_buf: [4096]u8 = undefined;
        const selected = try serializeChecklistSelections(items[0..], &selected_buf);
        const msg_tmp = try std.fmt.allocPrint(std.heap.c_allocator, "You chose to configure:\n\n{s}\n\nLet the rite begin...", .{selected});
        defer std.heap.c_allocator.free(msg_tmp);
        const msg = try std.heap.c_allocator.dupeZ(u8, msg_tmp);
        defer std.heap.c_allocator.free(msg);

        try showMsgBox(.{ .text = msg, .rows = 12, .cols = 60 });
    } else {
        try showMsgBox(.{
            .text = "You fled the chamber. No changes made to your fate.",
            .rows = 6,
            .cols = 60,
        });
    }
}

fn runExtrasChecklist() !void {
    var conf: c.struct_bsddialog_conf = undefined;
    initCliLikeConf(&conf);
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
        std.debug.print("Error: {s}\n", .{doombsd.session.getError()});
        return error.BSDDialogChecklistFailed;
    }

    if (output == c.BSDDIALOG_OK) {
        var selected_buf: [4096]u8 = undefined;
        const selected = try serializeChecklistSelections(items[0..], &selected_buf);
        const msg_tmp = try std.fmt.allocPrint(std.heap.c_allocator, "You selected:\n{s}", .{selected});
        defer std.heap.c_allocator.free(msg_tmp);
        const msg = try std.heap.c_allocator.dupeZ(u8, msg_tmp);
        defer std.heap.c_allocator.free(msg);

        try showMsgBox(.{ .text = msg, .rows = 10, .cols = 60 });
    } else {
        try showMsgBox(.{
            .text = "No extras selected. The void remains untouched.",
            .rows = 6,
            .cols = 60,
        });
    }
}

const MsgBoxOptions = struct {
    title: ?[*:0]const u8 = null,
    text: [*:0]const u8,
    rows: c_int,
    cols: c_int,
};

fn showMsgBox(options: MsgBoxOptions) !void {
    var conf: c.struct_bsddialog_conf = undefined;
    initCliLikeConf(&conf);
    conf.title = options.title;

    c.bsddialog_clear(0);
    const output = c.bsddialog_msgbox(&conf, options.text, options.rows, options.cols);
    if (output == c.BSDDIALOG_ERROR) {
        std.debug.print("Error: {s}\n", .{doombsd.session.getError()});
        return error.BSDDialogMsgBoxFailed;
    }
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

fn initCliLikeConf(conf: *c.struct_bsddialog_conf) void {
    _ = c.bsddialog_initconf(conf);
    conf.key.enable_esc = true;
    conf.button.always_active = true;
}

fn color(fg: c.enum_bsddialog_color, bg: c.enum_bsddialog_color, flags: c_uint) c_int {
    return c.bsddialog_color(fg, bg, flags);
}

fn applyDoomTheme() !void {
    var theme: c.struct_bsddialog_theme = undefined;
    if (c.bsddialog_get_theme(&theme) != c.BSDDIALOG_OK) {
        return error.BSDDialogGetThemeFailed;
    }

    theme.screen.color = color(c.BSDDIALOG_BLACK, c.BSDDIALOG_RED, 0);

    theme.shadow.color = color(c.BSDDIALOG_BLACK, c.BSDDIALOG_BLACK, 0);
    theme.shadow.y = 1;
    theme.shadow.x = 2;

    theme.dialog.color = color(c.BSDDIALOG_WHITE, c.BSDDIALOG_BLACK, 0);
    theme.dialog.delimtitle = true;
    theme.dialog.titlecolor = color(c.BSDDIALOG_RED, c.BSDDIALOG_BLACK, 0);
    theme.dialog.bottomtitlecolor = color(c.BSDDIALOG_WHITE, c.BSDDIALOG_BLACK, 0);
    theme.dialog.lineraisecolor = color(c.BSDDIALOG_RED, c.BSDDIALOG_BLACK, 0);
    theme.dialog.linelowercolor = color(c.BSDDIALOG_RED, c.BSDDIALOG_BLACK, 0);
    theme.dialog.arrowcolor = color(c.BSDDIALOG_BLACK, c.BSDDIALOG_RED, 0);

    theme.menu.f_selectorcolor = color(c.BSDDIALOG_RED, c.BSDDIALOG_BLACK, 0);
    theme.menu.selectorcolor = color(c.BSDDIALOG_WHITE, c.BSDDIALOG_BLACK, 0);

    theme.menu.f_prefixcolor = color(c.BSDDIALOG_BLACK, c.BSDDIALOG_BLACK, 0);
    theme.menu.prefixcolor = color(c.BSDDIALOG_BLACK, c.BSDDIALOG_BLACK, 0);

    theme.menu.f_namecolor = color(c.BSDDIALOG_RED, c.BSDDIALOG_BLACK, 0);
    theme.menu.namecolor = color(c.BSDDIALOG_WHITE, c.BSDDIALOG_BLACK, 0);

    theme.menu.f_desccolor = color(c.BSDDIALOG_RED, c.BSDDIALOG_BLACK, 0);
    theme.menu.desccolor = color(c.BSDDIALOG_WHITE, c.BSDDIALOG_BLACK, 0);

    theme.menu.f_shortcutcolor = color(c.BSDDIALOG_RED, c.BSDDIALOG_BLACK, 0);
    theme.menu.shortcutcolor = color(c.BSDDIALOG_WHITE, c.BSDDIALOG_BLACK, 0);

    theme.menu.bottomdesccolor = color(c.BSDDIALOG_BLACK, c.BSDDIALOG_RED, 0);
    theme.menu.sepnamecolor = color(c.BSDDIALOG_RED, c.BSDDIALOG_WHITE, 0);
    theme.menu.sepdesccolor = color(c.BSDDIALOG_RED, c.BSDDIALOG_WHITE, 0);

    theme.form.f_fieldcolor = color(c.BSDDIALOG_WHITE, c.BSDDIALOG_RED, c.BSDDIALOG_BOLD);
    theme.form.fieldcolor = color(c.BSDDIALOG_WHITE, c.BSDDIALOG_RED, c.BSDDIALOG_BOLD);
    theme.form.readonlycolor = color(c.BSDDIALOG_RED, c.BSDDIALOG_WHITE, c.BSDDIALOG_BOLD);
    theme.form.bottomdesccolor = color(c.BSDDIALOG_WHITE, c.BSDDIALOG_RED, 0);

    theme.bar.f_color = color(c.BSDDIALOG_WHITE, c.BSDDIALOG_RED, c.BSDDIALOG_BOLD);
    theme.bar.color = color(c.BSDDIALOG_RED, c.BSDDIALOG_WHITE, c.BSDDIALOG_BOLD);

    theme.button.minmargin = 1;
    theme.button.maxmargin = 5;
    theme.button.leftdelim = '[';
    theme.button.rightdelim = ']';
    theme.button.f_delimcolor = color(c.BSDDIALOG_BLACK, c.BSDDIALOG_RED, 0);
    theme.button.delimcolor = color(c.BSDDIALOG_WHITE, c.BSDDIALOG_BLACK, 0);
    theme.button.f_color = color(c.BSDDIALOG_BLACK, c.BSDDIALOG_RED, 0);
    theme.button.color = color(c.BSDDIALOG_WHITE, c.BSDDIALOG_BLACK, 0);
    theme.button.f_shortcutcolor = color(c.BSDDIALOG_BLACK, c.BSDDIALOG_RED, 0);
    theme.button.shortcutcolor = color(c.BSDDIALOG_WHITE, c.BSDDIALOG_BLACK, 0);

    if (c.bsddialog_set_theme(&theme) != c.BSDDIALOG_OK) {
        return error.BSDDialogSetThemeFailed;
    }
}
