pub const c = @import("c/bindings.zig").c;

pub const types = @import("bsddialog/types.zig");
pub const session = @import("bsddialog/session.zig");

pub const widgets = struct {
    pub const infobox = @import("bsddialog/widgets/infobox.zig");
    pub const msgbox = @import("bsddialog/widgets/msgbox.zig");
    pub const yesno = @import("bsddialog/widgets/yesno.zig");
};

pub const examples_library = struct {
    pub const infobox = @import("ports/examples_library/infobox.zig");
    pub const msgbox = @import("ports/examples_library/msgbox.zig");
    pub const yesno = @import("ports/examples_library/yesno.zig");
};
