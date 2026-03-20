const doombsd = @import("doombsd");

pub fn main() !void {
    try doombsd.examples_library.yesno.run();
}
