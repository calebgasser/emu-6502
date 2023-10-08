const std = @import("std");
const print = std.debug.print;

pub const MAX_MEM: u32 = 1024 * 64;

pub const Memory = struct {
    Data: [MAX_MEM]u8,

    pub fn init() Memory {
        return Memory{
            .Data = [_]u8{0} ** MAX_MEM,
        };
    }

    pub fn read_byte(this: *Memory, index: u32) u8 {
        return this.Data[index];
    }

    pub fn set_byte(this: *Memory, index: u32, value: u8) void {
        this.Data[index] = value;
    }

    pub fn print_state(this: *Memory, from: u32, to: u32) void {
        if (from < this.Data.len and to < this.Data.len) {
            print("Memory Addresses [{d}-{d}]\n", .{ from, to });
            for (from..to) |index| {
                print("{d}: 0x{X:0>4} ", .{ index, this.Data[index] });
                if (index > 0 and index % 10 == 0) {
                    print("\n", .{});
                }
            }
            print("\n", .{});
        }
    }
};
