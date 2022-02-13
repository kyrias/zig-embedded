const std = @import("std");

const lock = @import("lock.zig");
const usart = @import("usart.zig");

pub var loop: *Loop = undefined;
pub var in_event_loop = false;

pub const Queue = std.atomic.Queue(QueueEntry);
pub const QueueEntry = struct {
    frame: anyframe,
    data: union(enum) {
        none: void,
        usart: *usart.UsartOperation,
        lock: *lock.LockOperation,
    },
};

pub fn yield() void {
    suspend {
        var node = Queue.Node{
            .prev = undefined,
            .next = undefined,
            .data = .{
                .frame = @frame(),
                .data = .{ .none = {} },
            },
        };
        loop.completion_handler.queue.put(&node);
    }
}

pub const Loop = struct {
    completion_handler: CompletionHandler,
    usart_processor: usart.UsartProcessor,
    lock_processor: lock.LockProcessor,

    pub fn init(self: *Loop) void {
        self.* = Loop{
            .completion_handler = undefined,
            .usart_processor = undefined,
            .lock_processor = undefined,
        };
        self.completion_handler.init();
        self.usart_processor.init();
        self.lock_processor.init();

        loop = self;
    }

    pub fn deinit(self: *Loop) void {
        self.* = undefined;
        loop = undefined;
    }

    pub fn run(self: *Loop) void {
        in_event_loop = true;

        while (true) {
            // First dispatch any already completed async operations.
            self.completion_handler.dispatch();

            // Check if there are any USART operations that are ready to be executed.
            self.usart_processor.dispatch();

            // Check if there are any lock requests that can be fulfilled.
            self.lock_processor.dispatch();

            const done = self.completion_handler.isDone() and self.usart_processor.isDone() and self.lock_processor.isDone();
            if (done) {
                break;
            }
        }

        in_event_loop = false;
    }
};

pub const CompletionHandler = struct {
    queue: Queue,

    pub fn init(self: *CompletionHandler) void {
        self.* = CompletionHandler{
            .queue = Queue.init(),
        };
    }

    pub fn dispatch(self: *CompletionHandler) void {
        while (true) {
            const completion_event = self.queue.get() orelse return;
            resume completion_event.data.frame;
        }
    }

    pub fn isDone(self: *CompletionHandler) bool {
        return self.queue.isEmpty();
    }
};
