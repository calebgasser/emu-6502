const std = @import("std");
const print = std.debug.print;

pub const MAX_MEM: u32 = 1024 * 64;

pub const Memory = struct {
    Data: [MAX_MEM]u8,

    pub fn build() Memory {
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

    pub fn set_word(this: *Memory, index: u32, value: u16) void {
        this.Data[index] = value & 0xFF;
        this.Data[index + 1] = (value >> 8);
    }

    pub fn print_state(this: *Memory, from: u32, to: u32) void {
        if (from < this.Data.len and to < this.Data.len) {
            print("Memory Addresses [{d}-{d}]\n", .{ from, to });
            for (from..to) |index| {
                print("[0x{X}: 0x{X:0>4}] ", .{ index, this.Data[index] });
                if (index != from and index % 4 == 0) {
                    print("\n", .{});
                }
            }
            print("\n", .{});
        }
    }
};
