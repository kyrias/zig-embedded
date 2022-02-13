const std = @import("std");

const loop = @import("loop.zig");
const regs = @import("devices/stm32f1.zig");
const usart = @import("usart.zig");

pub const ev_writer = std.io.Writer(void, error{}, usart.usart3_writer){ .context = {} };
pub const raw_writer = std.io.Writer(void, error{}, raw_usart3_writer){ .context = {} };

/// Implements the logger function used for all stdlib logging.
pub fn log(
    comptime message_level: std.log.Level,
    comptime scope: @Type(.EnumLiteral),
    comptime format: []const u8,
    args: anytype,
) void {
    const level_txt = comptime message_level.asText();
    const prefix = if (scope == .default) ": " else "(" ++ @tagName(scope) ++ "): ";

    if (loop.in_event_loop) {
        try std.fmt.format(ev_writer, level_txt ++ prefix ++ format ++ "\r\n", args);
    } else {
        try std.fmt.format(raw_writer, level_txt ++ prefix ++ format ++ "\r\n", args);
    }
}

pub fn raw_usart3_writer(context: void, bytes: []const u8) !usize {
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

pub fn configure_log_usart() void {
    // USART3 on GPIOB
    regs.RCC.APB1ENR.modify(.{ .USART3EN = 0b1 });
    regs.RCC.APB2ENR.modify(.{ .IOPBEN = 0b1 });

    // Reset USART3 and GPIOB
    regs.RCC.APB1RSTR.modify(.{ .USART3RST = 0b1 });
    regs.RCC.APB2RSTR.modify(.{ .IOPBRST = 0b1 });
    regs.RCC.APB1RSTR.modify(.{ .USART3RST = 0b0 });
    regs.RCC.APB2RSTR.modify(.{ .IOPBRST = 0b0 });

    // PB10 TX output, alternate function push-pull
    regs.GPIOB.CRH.modify(.{ .MODE10 = 0b01, .CNF10 = 0b10 });

    // PB11 RX input, floating
    regs.GPIOB.CRH.modify(.{ .MODE11 = 0b00, .CNF11 = 0b01 });

    regs.USART3.CR1.modify(.{ .UE = 0b1 });

    regs.USART3.BRR.write(.{ .DIV_Mantissa = 19, .DIV_Fraction = 8 });

    regs.USART3.CR1.modify(.{
        .TE = 0b1,
        .RE = 0b1,
    });
}
