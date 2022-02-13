const std = @import("std");
const build_options = @import("build_options");
const startup = @import("startup");

const interrupts = @import("interrupts.zig");
const regs = @import("devices/stm32f1.zig");

// stdlib hooks
usingnamespace struct {
    // The stdlib uses root.log for writing all log messages.
    pub const log = @import("log.zig").log;

    pub fn panic(msg: []const u8, error_return_trace: ?*std.builtin.StackTrace) noreturn {
        _ = error_return_trace;

        const writer = @import("log.zig").writer;
        std.fmt.format(writer, "panic: {s}\r\n", .{msg}) catch {};

        while (true) {
            asm volatile ("WFI");
        }
    }
};

const startup_device = @field(startup.Device, @tagName(build_options.device));
const VectorTable = startup.VectorTable;
export const vector_table linksection(".vector_table") = VectorTable(main, startup_device).init(.{});

fn set_clock() void {
    // Set PLLMUL to x9, don't divide HSE before PLL, pass HSE into PLL, and APB1 to divide by 2.
    regs.RCC.CFGR.modify(.{ .PLLMUL = 0b0111, .PLLXTPRE = 0b0, .PLLSRC = 0b1, .PPRE1 = 0b100 });
    regs.RCC.CR.modify(.{ .PLLON = 0b1, .HSEON = 0b1 });

    // Wait until both HSE and PLL is ready.
    var cr = regs.RCC.CR.read();
    while (cr.HSERDY != 0b1 or cr.PLLRDY != 0b1) {
        cr = regs.RCC.CR.read();
    }

    // Set flash latency to two wait states.  If this is too slow for the set
    // SYSCLK speed the processor will trap as it couldn't read the
    // instructions in time.
    // 000 Zero wait state, if 0      < SYSCLK <= 24 MHz
    // 001 One wait state,  if 24 MHz < SYSCLK <= 48 MHz
    // 010 Two wait states, if 48 MHz < SYSCLK <= 72 MHz
    regs.FLASH.ACR.modify(.{ .LATENCY = 0b010 });

    // Set SYSCLK source to PLL and wait until we've switched over.
    regs.RCC.CFGR.modify(.{ .SW = 0b10 });
    while (regs.RCC.CFGR.read().SWS != 0b10) {}
}

fn configure_log_usart() void {
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

pub fn main() void {
    set_clock();

    configure_log_usart();
    std.log.info("Configured log USART", .{});

    interrupts.init();
    std.log.info("Performed interrupt initialization", .{});

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
