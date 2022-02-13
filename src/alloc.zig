const alignBackward = std.mem.alignBackward;
const alignForward = std.mem.alignForward;
const std = @import("std");

pub const Block = packed struct {
    data_size: usize,
    previous: ?*Block,
    next: ?*Block,
    alignment: u29,
    block_free: bool,

    pub fn dataPtr(self: *Block) *u8 {
        const data_addr = @ptrToInt(self) + @sizeOf(Block);
        const aligned_data_addr = if (self.alignment > 0) alignForward(data_addr, self.alignment) else data_addr;
        return @intToPtr(*u8, aligned_data_addr);
    }

    pub fn fromDataPtr(data_ptr: *u8, alignment: u29) *Block {
        const data_addr = @ptrToInt(data_ptr);
        const unaligned_block_addr = data_addr - @sizeOf(Block);
        const aligned_block_addr = if (alignment > 0) alignForward(unaligned_block_addr, alignment) else unaligned_block_addr;
        return @intToPtr(*Block, aligned_block_addr);
    }

    pub fn new(heap_bottom: usize, heap_size: usize) !?*Block {
        var aligned_addr = alignForward(heap_bottom, @alignOf(Block));

        var metadata_overhead = (aligned_addr - heap_bottom) + @sizeOf(Block);
        if (heap_size < metadata_overhead) {
            return error.HeapAreaTooSmallForBlockMetadata;
        }

        var block = @intToPtr(*Block, aligned_addr);
        block.* = .{
            .block_free = true,
            .alignment = 0,
            .data_size = heap_size - metadata_overhead,
            .previous = null,
            .next = null,
        };
        return block;
    }

    pub fn allocate(self: *Block, requested_size: usize, requested_alignment: u29) !?*Block {
        if (!self.block_free) {
            if (self.next) |next| {
                return next.allocate(requested_size, requested_alignment);
            } else {
                return error.OutOfMemory;
            }
        }

        const current_block_addr = @ptrToInt(self);
        const current_data_addr = current_block_addr + @sizeOf(Block);
        const current_data_size = self.data_size;

        {
            // Check that this block is big enough for the requested allocation.
            const current_metadata_overhead = alignForward(current_data_addr, requested_alignment) - current_data_addr;
            if (current_data_size - current_metadata_overhead < requested_size) {
                if (self.next) |next| {
                    return next.allocate(requested_size, requested_alignment);
                } else {
                    return error.OutOfMemory;
                }
            }
        }

        var middle = self;
        const middle_data_addr = alignForward(current_data_addr, requested_alignment);
        {
            const middle_block_addr = alignBackward(middle_data_addr - @sizeOf(Block), requested_alignment);
            if (middle_block_addr > current_block_addr) {
                middle = @intToPtr(*Block, middle_block_addr);
                // This allocation forces us to create a dummy block so that we can
                // reliably go from data ptr -> block ptr.
                var left = self;
                const middle_data_size = current_data_size - (middle_data_addr - current_data_addr);
                middle.* = .{
                    .block_free = true,
                    .alignment = requested_alignment,
                    .data_size = middle_data_size,
                    .previous = left,
                    .next = null,
                };

                const left_data_size = middle_block_addr - current_data_addr;
                left.data_size = left_data_size;
                left.next = middle;
            }
        }

        {
            // If there is enough space at the end for another block, perform the split.
            const right_block_addr = alignForward(middle_data_addr + requested_size, @alignOf(Block));
            const right_data_addr = right_block_addr + @sizeOf(Block);
            var right = @intToPtr(*Block, right_block_addr);
            if (right_data_addr - middle_data_addr <= middle.data_size) {
                right.* = .{
                    .block_free = true,
                    .alignment = 0,
                    .data_size = middle.data_size - (right_data_addr - middle_data_addr),
                    .previous = middle,
                    .next = null,
                };

                middle.data_size = right_block_addr - middle_data_addr;
                middle.next = right;
            }
        }

        middle.block_free = false;
        return middle;
    }

    pub fn free(self: *Block) void {
        self.block_free = true;

        // First find the first free block
        var first_free = self;
        while (first_free.previous) |prev| : (first_free = prev) {
            if (!prev.block_free) {
                break;
            }
        }

        // Then merge all free blocks that follow the first free block found.
        var block = first_free;
        while (block.next) |next| : (block = next) {
            if (!next.block_free) {
                break;
            }

            first_free.data_size += @sizeOf(Block) + next.data_size;
            first_free.next = next.next;
        }
    }

    pub fn dump(self: *Block) void {
        std.log.info("Dumping blocks:", .{});
        var i: usize = 0;
        var maybe_block: ?*Block = self;
        while (maybe_block) |block| : (maybe_block = block.next) {
            std.log.info("Block {}: {*} free?{} size?{} previous?{*} next?{*}", .{ i, block, block.block_free, block.data_size, block.previous, block.next });
            i += 1;
        }
    }
};
