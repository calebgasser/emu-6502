const std = @import("std");
const print = std.debug.print;
const Memory = @import("memory.zig").Memory;
const OpCodes = @import("opcodes.zig").OpCodes;

pub const CpuError = error{
    OutOfCycles,
};

pub const Registers = struct {
    A: u8, // accumulator
    X: u8, // index
    Y: u8, // index
};

pub const StatusFlags = struct {
    N: u1, // Negative
    V: u1, // Overflow
    B: u1, // Break
    D: u1, // Decimal
    I: u1, // Interupt Disable
    Z: u1, // Zero
    C: u1, // Carry
};

pub const CPU = struct {
    cycles: u32, // Cpu Cycles Remaining
    SP: u8, // Stack Pointer
    PC: u16, // Program Counter
    registers: Registers,
    flags: StatusFlags,

    pub fn print_state(this: *CPU) void {
        print("{s:->80}\n", .{""});
        print("(Stack Pointer)...SP: 0x{X:0>8}\n", .{this.SP});
        print("(Program Counter).PC: 0x{X:0>16}\n", .{this.PC});
        print("(Accumulator).....A:  0x{X:0>8}\n", .{this.registers.A});
        print("(Index)...........X:  0x{X:0>8}\n", .{this.registers.X});
        print("(Index)...........Y:  0x{X:0>8}\n", .{this.registers.Y});
        print(".......Flags........\n", .{});
        print("(Negative).N:    {d} | (Overflow).........V:    {d} | (Break).B:   {d}\n", .{ this.flags.N, this.flags.V, this.flags.B });
        print("(Decimal)..D:    {d} | (Interupt Disable).I:    {d} | (Zero)..Z:   {d}\n", .{ this.flags.D, this.flags.I, this.flags.Z });
        print("(Carry)....C:    {d} |\n", .{this.flags.C});
        print("{s:->80}\n", .{""});
    }

    pub fn consume_cycles(this: *CPU, num: u32) CpuError!void {
        if (this.cycles <= 0 or (this.cycles - num) < 0) {
            return CpuError.OutOfCycles;
        } else {
            this.cycles -= num;
        }
    }

    pub fn add_cycles(this: *CPU, num_cycles: u32) void {
        this.cycles += num_cycles;
    }

    pub fn fetch_byte(this: *CPU, mem: *Memory) CpuError!u8 {
        var data = mem.read_byte(this.PC);
        this.PC += 1;
        try this.consume_cycles(1);
        return data;
    }

    pub fn lda_im(this: *CPU, mem: *Memory) !void {
        var value_A = try this.fetch_byte(mem);
        if (value_A == 0) {
            this.flags.Z = 1;
        } else {
            this.flags.Z = 0;
        }
        if ((value_A & 0b10000000) > 0) {
            this.flags.N = 1;
        } else {
            this.flags.N = 0;
        }
        this.registers.A = value_A;
    }

    pub fn execute(this: *CPU, mem: *Memory) CpuError!void {
        while (this.cycles > 0) {
            var byte = try this.fetch_byte(mem);
            var byte_enum: OpCodes = @enumFromInt(byte);
            try switch (byte_enum) {
                OpCodes.LDA_IM => this.lda_im(mem),
            };
        }
    }

    pub fn LDA() void {}

    pub fn init() CPU {
        return CPU{ .cycles = 0, .SP = 0x00000000, .PC = 0x0000000000000000, .registers = .{
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
