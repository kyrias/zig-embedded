const root = @import("root");

usingnamespace @import("startup/vector_table.zig");

// Bottom of stack, i.e. highest address in the stack range.
extern var __stack_start: u32;

// LMA is the load-time address, VMA is the virtual address in RAM that the data will be copied to.
extern var __data_lma_size: u32;
extern var __data_lma_start: u32;
extern var __data_vma_start: u32;

extern var __bss_size: u32;
extern var __bss_start: u32;

export fn Reset_Handler() callconv(.AAPCS) void {
    const data_size = @ptrToInt(&__data_lma_size);
    const data_lma = @ptrCast([*]u8, &__data_lma_start);
    const data_vma = @ptrCast([*]u8, &__data_vma_start);
    for (data_lma[0..data_size]) |b, i| {
        data_vma[i] = b;
    }

    const bss_size = @ptrToInt(&__bss_size);
    const bss = @ptrCast([*]u8, &__bss_start);
    for (bss[0..bss_size]) |*b| b.* = 0;

    root.main();
}

export fn Default_Handler() void {
    while (true) {}
}
