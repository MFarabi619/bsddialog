const std = @import("std");

const c = @cImport({
    @cInclude("locale.h");
    @cInclude("bsddialog.h");
});

pub fn main() !void {
    _ = c.setlocale(c.LC_ALL, "");

    if (c.bsddialog_init() == c.BSDDIALOG_ERROR) {
        std.debug.print("Error: {s}\n", .{c.bsddialog_geterror()});
        return error.BSDDialogInitFailed;
    }
    defer _ = c.bsddialog_end();

    var conf: c.struct_bsddialog_conf = undefined;
    _ = c.bsddialog_initconf(&conf);
    conf.title = "infobox";
    conf.sleep = 3;

    const rv = c.bsddialog_infobox(
        &conf,
        "Hello from Zig + libbsddialog",
        7,
        40,
    );
    if (rv == c.BSDDIALOG_ERROR) {
        std.debug.print("Error: {s}\n", .{c.bsddialog_geterror()});
        return error.BSDDialogInfoboxFailed;
    }
}
