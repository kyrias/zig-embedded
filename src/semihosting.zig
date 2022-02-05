// TODO: Would be nice if we wolud notify the user if an assert fails...
const assert = @import("std").debug.assert;

pub const SYS_OPEN: usize = 0x01;
pub const SYS_CLOSE: usize = 0x02;
pub const SYS_WRITEC: usize = 0x03;
pub const SYS_WRITE0: usize = 0x04;
pub const SYS_WRITE: usize = 0x05;

pub const OpenMode = enum(u4) {
    r = 0,
    rb = 1,
    @"r+" = 2,
    @"r+b" = 3,
    w = 4,
    wb = 5,
    @"w+" = 6,
    @"w+b" = 7,
    a = 8,
    ab = 9,
    @"a+" = 10,
    @"a+b" = 11,
};

/// Open a file through the debugger interface.
///
/// The ARM manual says that :tt should be supported for a stdin/stdout-type
/// stream.  st-utils does not implement this, and will instead literally open
/// a file called :tt.
pub fn sys_open(path: []const u8, mode: OpenMode) usize {
    const OpenArg = packed struct {
        path: [*]const u8,
        mode: u32,
        length: u32,
    };
    const arg: OpenArg = .{
        .path = path.ptr,
        .mode = @enumToInt(mode),
        .length = path.len,
    };

    const fd = asm volatile (
        \\BKPT #0xAB
        : [ret] "={r0}" (-> usize),
        : [SYS_OPEN] "{r0}" (SYS_OPEN),
          [arg] "{r1}" (arg),
        : "r0"
    );

    assert(fd > 0);

    return fd;
}

/// Close a file descriptor opened by sys_open.
pub fn sys_close(fd: usize) void {
    const CloseArg = packed struct {
        fd: u32,
    };
    const arg: CloseArg = .{
        .fd = fd,
    };

    const ret = asm volatile (
        \\BKPT #0xAB
        : [ret] "={r0}" (-> usize),
        : [SYS_CLOSE] "{r0}" (SYS_CLOSE),
          [arg] "{r1}" (arg),
        : "r0"
    );

    assert(ret == 0);
}

/// Write a single character to the debugger output.
pub fn sys_writec(char: u8) void {
    asm volatile (
        \\BKPT #0xAB
        :
        : [SYS_WRITEC] "{r0}" (SYS_WRITEC),
          [char] "{r1}" (&char),
        : "r0"
    );
}

/// Write a null-terminated string to the debugger output.
pub fn sys_write0(str: [:0]const u8) void {
    const arg = str.ptr;
    asm volatile (
        \\BKPT #0xAB
        :
        : [SYS_WRITE0] "{r0}" (SYS_WRITE0),
          [arg] "{r1}" (arg),
        : "r0"
    );
}

/// Write a byte string to the given file descriptor.
pub fn sys_write(fd: u32, str: []const u8) usize {
    const WriteArg = packed struct {
        fd: u32,
        str: [*]const u8,
        length: u32,
    };
    const arg: WriteArg = .{
        .fd = fd,
        .str = str.ptr,
        .length = str.len,
    };

    const ret = asm volatile (
        \\BKPT #0xAB
        : [ret] "={r0}" (-> usize),
        : [SYS_WRITE] "{r0}" (SYS_WRITE),
          [arg] "{r1}" (arg),
        : "r0"
    );

    assert(ret == 0);

    return ret;
}
