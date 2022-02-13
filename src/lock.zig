const loop = @import("loop.zig");

pub const LockOperation = struct {
    lock: *Lock,

    pub fn execute(self: *LockOperation) bool {
        return (@cmpxchgWeak(Lock.State, &self.lock.state, Lock.State.unlocked, Lock.State.locked, .SeqCst, .SeqCst) == null);
    }
};

pub const LockProcessor = struct {
    queue: loop.Queue,

    pub fn init(self: *LockProcessor) void {
        self.* = LockProcessor{
            .queue = loop.Queue.init(),
        };
    }

    pub fn dispatch(self: *LockProcessor) void {
        var remaining = loop.Queue.init();
        while (self.queue.get()) |node| {
            switch (node.data.data) {
                .lock => {},
                else => unreachable,
            }

            if (node.data.data.lock.execute()) {
                loop.loop.completion_handler.queue.put(node);
            } else {
                remaining.put(node);
            }
        }
        self.queue = remaining;
    }

    pub fn isDone(self: *LockProcessor) bool {
        return self.queue.isEmpty();
    }

    pub fn schedule(self: *LockProcessor, operation: *LockOperation) void {
        suspend {
            var node = loop.Queue.Node{
                .prev = undefined,
                .next = undefined,
                .data = loop.QueueEntry{
                    .frame = @frame(),
                    .data = .{ .lock = operation },
                },
            };
            self.queue.put(&node);
        }
    }
};

pub const Lock = struct {
    state: State = .unlocked,

    const State = enum {
        unlocked,
        locked,
    };

    pub fn lock(self: *Lock) void {
        loop.loop.lock_processor.schedule(&.{ .lock = self });
    }

    pub fn unlock(self: *Lock) void {
        if (@cmpxchgStrong(State, &self.state, .locked, .unlocked, .SeqCst, .SeqCst) != null) {
            unreachable;
        }
    }
};
