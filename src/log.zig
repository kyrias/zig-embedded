const std = @import("std");

const regs = @import("devices/stm32f1.zig");
const semihosting = @import("semihosting.zig");

pub const writer = std.io.Writer(void, error{}, usart3_writer){ .context = {} };

/// Implements the logger function used for all stdlib logging.
pub fn log(
    comptime message_level: std.log.Level,
    comptime scope: @Type(.EnumLiteral),
    comptime format: []const u8,
    args: anytype,
) void {
    const level_txt = comptime message_level.asText();
    const prefix = if (scope == .default) ": " else "(" ++ @tagName(scope) ++ "): ";

    try std.fmt.format(
        writer,
        level_txt ++ prefix ++ format ++ "\r\n",
        args,
    );
}

pub fn usart3_writer(context: void, bytes: []const u8) !usize {
    // The Writer interface expects us to have a context type, which would
    // normally be something like a File.  Since we're just performing the
    // equivalent of a syscall, we just accept void and do nothing with it.
    _ = context;

    for (bytes) |byte| {
        while (regs.USART3.SR.read().TXE == 0b0) {}
        regs.USART3.DR.write(.{ .DR = byte });
    }

    return bytes.len;
}
