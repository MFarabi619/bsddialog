const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe_root = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const exe = b.addExecutable(.{
        .name = "doombsd-installer",
        .root_module = exe_root,
    });

    exe.root_module.link_libc = true;
    exe.root_module.addIncludePath(b.path("lib"));
    exe.addLibraryPath(b.path("lib"));
    exe.linkSystemLibrary("bsddialog");

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the DoomBSD installer demo");
    run_step.dependOn(&run_cmd.step);
}
