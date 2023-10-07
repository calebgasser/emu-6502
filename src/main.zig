const std = @import("std");
const print = std.debug.print;

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

const Instruction = enum(u8) {
    LDA = 0xA9, // Load accumulator
};

const CPU = struct {
    SP: u8, // Stack Pointer
    PC: u16, // Program Counter
    registers: Registers,
    flags: StatusFlags,

    pub fn print_state(this: *CPU) void {
        print("{s:->30}\n", .{""});
        print("SP: 0x{X} | PC: 0x{X} |\n", .{ this.SP, this.PC });
        print("A:  0x{X} | X:  0x{X} | Y: 0x{X}\n", .{ this.registers.A, this.registers.X, this.registers.Y });
        print("N:    {d} | V:    {d} | B:   {d}\n", .{ this.flags.N, this.flags.V, this.flags.B });
        print("D:    {d} | I:    {d} | Z:   {d}\n", .{ this.flags.D, this.flags.I, this.flags.Z });
        print("C:    {d} |\n", .{this.flags.C});
        print("{s:->30}\n", .{""});
    }

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
    cpu.print_state();
}
