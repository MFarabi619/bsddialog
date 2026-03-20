const std = @import("std");
const doombsd = @import("../../root.zig");

const session = doombsd.session;
const types = doombsd.types;
const infobox_widget = doombsd.widgets.infobox;

pub fn run() !void {
    var output: types.Result = undefined;
    var conf: doombsd.c.struct_bsddialog_conf = undefined;

    session.setLocale();

    session.init() catch {
        std.debug.print("Error: {s}\n", .{session.getError()});
        return error.BSDDialogInitFailed;
    };
    defer session.end();

    output = try infobox_widget.show(&conf, .{
        .title = "infobox",
        .text = "Example\n(3 seconds)",
        .rows = 7,
        .cols = 20,
        .sleep = 3,
    });

    if (output == .@"error") {
        std.debug.print("Error: {s}\n", .{session.getError()});
        return error.BSDDialogInfoboxFailed;
    }
}
