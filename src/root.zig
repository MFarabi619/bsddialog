pub const c = @import("c/bindings.zig").c;

pub const types = @import("bsddialog/types.zig");
pub const session = @import("bsddialog/session.zig");

pub const widgets = struct {
    pub const infobox = @import("bsddialog/widgets/infobox.zig");
};

pub const examples_library = struct {
    pub const infobox = @import("ports/examples_library/infobox.zig");
};
