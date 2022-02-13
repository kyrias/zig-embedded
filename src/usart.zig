const std = @import("std");

const loop = @import("loop.zig");
const regs = @import("devices/stm32f1.zig");

pub const UsartOperation = struct {
    usart: enum {
        USART3,
    },
    direction: enum {
        Receive,
        Transmit,
    },
    byte: ?u8,

    pub fn ready(self: *UsartOperation) bool {
        const reg = switch (self.usart) {
            .USART3 => regs.USART3,
        };
        return switch (self.direction) {
            .Receive => reg.SR.read().RXNE == 0b1,
            .Transmit => reg.SR.read().TXE == 0b1,
        };
    }

    pub fn execute(self: *UsartOperation) void {
        const reg = switch (self.usart) {
            .USART3 => regs.USART3,
        };
        switch (self.direction) {
            .Receive => self.byte = @truncate(u8, reg.DR.read().DR),
            .Transmit => reg.DR.write(.{ .DR = self.byte.? }),
        }
    }
};

pub const UsartProcessor = struct {
    queue: loop.Queue,

    pub fn init(self: *UsartProcessor) void {
        self.* = UsartProcessor{
            .queue = loop.Queue.init(),
        };
    }

    pub fn dispatch(self: *UsartProcessor) void {
        var remaining = loop.Queue.init();
        while (self.queue.get()) |node| {
            switch (node.data.data) {
                .usart => {},
                else => unreachable,
            }

            var operation = node.data.data.usart;
            if (!operation.ready()) {
                remaining.put(node);
                continue;
            }

            operation.execute();
            loop.loop.completion_handler.queue.put(node);
        }
        self.queue = remaining;
    }

    pub fn isDone(self: *UsartProcessor) bool {
        return self.queue.isEmpty();
    }

    pub fn schedule(self: *UsartProcessor, operation: UsartOperation) ?u8 {
        var op = operation;
        suspend {
            var node = loop.Queue.Node{
                .prev = undefined,
                .next = undefined,
                .data = loop.QueueEntry{
                    .frame = @frame(),
                    .data = .{ .usart = &op },
                },
            };
            self.queue.put(&node);
        }
        return op.byte;
    }
};

pub fn usart3_writer(context: void, bytes: []const u8) !usize {
    // The Writer interface expects us to have a context type, which would
    // normally be something like a File.  Since we're just performing the
    // equivalent of a syscall, we just accept void and do nothing with it.
    _ = context;
    loop.yield();

    for (bytes) |byte| {
        const operation = UsartOperation{
            .usart = .USART3,
            .direction = .Transmit,
            .byte = byte,
        };
        _ = loop.loop.usart_processor.schedule(operation);
    }

    return bytes.len;
}
