const std = @import("std");
const build_options = @import("build_options");
const startup = @import("startup");

const regs = @import("devices/stm32f1.zig");

// stdlib hooks
usingnamespace struct {
    // The stdlib uses root.log for writing all log messages.
    pub const log = @import("log.zig").log;
};

const startup_device = @field(startup.Device, @tagName(build_options.device));
const VectorTable = startup.VectorTable;
export const vector_table linksection(".vector_table") = VectorTable(main, startup_device).init(.{});

pub fn main() void {
    regs.RCC.APB2ENR.modify(.{ .IOPCEN = 1 });
    regs.RCC.APB2RSTR.modify(.{ .IOPCRST = 1 });
    regs.RCC.APB2RSTR.modify(.{ .IOPCRST = 0 });

    // Set PC13 high before enabling output to prevent LED from being on before we enter the loop.
    regs.GPIOC.BSRR.write(.{ .BS13 = 0b1 });

    // SetPC13 to push-pull 2MHz output.
    regs.GPIOC.CRH.modify(.{ .CNF13 = 0b00, .MODE13 = 0b10 });

    while (true) {
        regs.GPIOC.BSRR.write(.{ .BR13 = 0b1 });

        var i: usize = 0;
        while (i < 400000) : (i += 1) {
            asm volatile ("");
        }

        regs.GPIOC.BSRR.write(.{ .BS13 = 0b1 });

        i = 0;
        while (i < 400000) : (i += 1) {
            asm volatile ("");
        }
    }
}
