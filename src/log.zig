const std = @import("std");

const semihosting = @import("semihosting.zig");

/// Implements the logger function used for all stdlib logging.
pub fn log(
    comptime message_level: std.log.Level,
    comptime scope: @Type(.EnumLiteral),
    comptime format: []const u8,
    args: anytype,
) void {
    const level_txt = comptime message_level.asText();
    const prefix = if (scope == .default) ": " else "(" ++ @tagName(scope) ++ "): ";
    const writer = std.io.Writer(void, error{}, debug_writer){ .context = {} };

    try std.fmt.format(
        writer,
        level_txt ++ prefix ++ format ++ "\n",
        args,
    );
}

fn debug_writer(context: void, bytes: []const u8) !usize {
    // The Writer interface expects us to have a context type, which would
    // normally be something like a File.  Since we're just performing the
    // equivalent of a syscall, we just accept void and do nothing with it.
    _ = context;

    _ = semihosting.sys_write(1, bytes);
    return bytes.len;
}
