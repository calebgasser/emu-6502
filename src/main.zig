const std = @import("std");

const Registers = struct {
    A: u8, // accumulator
    X: u8, // index
    Y: u8, // index
};

const StatusFlags = struct {
    N: u1, // Negative
    V: u1, // Overflow
    B: u1, // Break
    D: u1, // Decimal
    I: u1, // Interupt Disable
    Z: u1, // Zero
    C: u1, // Carry
};

const CPU = struct {
    SP: u8, // Stack Pointer
    PC: u16, // Program Counter
    registers: Registers,
    flags: StatusFlags,

    pub fn Reset() CPU {
        return CPU{ .SP = 0x00000000, .PC = 0x0000000000000000, .registers = .{
            .A = 0x0000,
            .X = 0x0000,
            .Y = 0x0000,
        }, .flags = .{
            .N = 0,
            .V = 0,
            .B = 0,
            .D = 0,
            .I = 0,
            .Z = 0,
            .C = 0,
        } };
    }
};

pub fn main() !void {
    var cpu = CPU.Reset();
    std.debug.print("{d} {d}", .{ cpu.SP, cpu.PC });
}
