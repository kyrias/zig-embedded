const std = @import("std");

/// MCUs supported by this project.
const Device = enum {
    STM32F103C8,

    pub fn target(device: Device) std.zig.CrossTarget {
        switch (device) {
            .STM32F103C8 => {
                return std.zig.CrossTarget.parse(.{
                    .arch_os_abi = "thumb-freestanding-none",
                    .cpu_features = "cortex_m3",
                }) catch unreachable;
            },
        }
    }
};

pub fn build(b: *std.build.Builder) void {
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const device = b.option(Device, "device", "Which device we're building for") orelse Device.STM32F103C8;
    const target = device.target();

    const build_options = b.addOptions();
    build_options.addOption(Device, "device", device);

    const exe = b.addExecutable("main.elf", "src/main.zig");
    exe.addOptions("build_options", build_options);
    exe.addPackage(.{
        .name = "startup",
        .path = .{ .path = "pkgs/startup/lib.zig" },
    });

    exe.setTarget(target);
    exe.setBuildMode(mode);
    switch (device) {
        .STM32F103C8 => exe.setLinkerScriptPath(.{ .path = "ld/stm32f103c8.ld" }),
    }

    exe.install();
    b.default_step.dependOn(&exe.step);
}
