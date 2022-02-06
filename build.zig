const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const target = std.zig.CrossTarget.parse(.{
        .arch_os_abi = "thumb-freestanding-none",
        .cpu_features = "cortex_m3",
    }) catch unreachable;

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("main.elf", "src/main.zig");
    exe.addPackage(.{
        .name = "startup",
        .path = .{ .path = "pkgs/startup/lib.zig" },
    });

    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.setLinkerScriptPath(.{ .path = "ld/stm32f103c8.ld" });
    exe.install();
    b.default_step.dependOn(&exe.step);
}
