const std = @import("std");
const build_options = @import("build_options");
const startup = @import("startup");

const interrupts = @import("interrupts.zig");
const logging = @import("logging.zig");
const loop = @import("loop.zig");
const regs = @import("devices/stm32f1.zig");

// stdlib hooks
usingnamespace struct {
    // The stdlib uses root.log for writing all log messages.
    pub const log = logging.log;

    pub fn panic(msg: []const u8, error_return_trace: ?*std.builtin.StackTrace) noreturn {
        _ = error_return_trace;

        std.fmt.format(logging.raw_writer, "panic: {s}\r\n", .{msg}) catch {};

        while (true) {
            asm volatile ("WFI");
        }
    }
};

const startup_device = @field(startup.Device, @tagName(build_options.device));
const VectorTable = startup.VectorTable;
export const _ linksection(".vector_table") = VectorTable(main, startup_device).init(.{});

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

pub fn main() void {
    set_clock();

    logging.configure_log_usart();
    std.log.info("Configured log USART", .{});

    interrupts.init();
    std.log.info("Performed interrupt initialization", .{});

    var event_loop: loop.Loop = undefined;
    event_loop.init();
    defer event_loop.deinit();

    std.log.info("Starting event loop", .{});
    _ = async event_loop.run();
    std.log.info("Event loop exited", .{});

    std.log.info("Exiting main", .{});
}
