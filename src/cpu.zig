const std = @import("std");
const print = std.debug.print;
const logger = @import("logger.zig");
const Memory = @import("memory.zig").Memory;
const OpCodes = @import("opcodes.zig").OpCodes;

pub const CpuError = error{
    OutOfCycles,
    InvalidOpCode,
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
    SP: u16, // Stack Pointer
    PC: u16, // Program Counter
    registers: Registers,
    flags: StatusFlags,
    logger: logger.Logger,

    pub fn print_state(this: *CPU) void {
        print("{s:->80}\n", .{""});
        print("(Stack Pointer)...SP: 0x{X:0>16}\n", .{this.SP});
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

    pub fn fetch_word(this: *CPU, mem: *Memory) CpuError!u16 {
        // 6502 is little endian
        var data = mem.read_byte(this.PC);
        this.PC += 1;
        try this.consume_cycles(1);

        data |= (mem.read_byte(this.PC) << 8);
        this.PC += 1;
        try this.consume_cycles(1);
        return data;
    }

    pub fn read_byte(this: *CPU, address: u8, mem: *Memory) CpuError!u8 {
        var data = mem.read_byte(address);
        try this.consume_cycles(1);
        return data;
    }

    fn lda_set_status(this: *CPU) void {
        if (this.registers.A == 0) {
            this.flags.Z = 1;
        } else {
            this.flags.Z = 0;
        }
        if ((this.registers.A & 0b10000000) > 0) {
            this.flags.N = 1;
        } else {
            this.flags.N = 0;
        }
    }

    pub fn lda_im(this: *CPU, mem: *Memory) !void {
        var value_A = try this.fetch_byte(mem);
        this.registers.A = value_A;
        this.lda_set_status();
    }

    pub fn lda_zp(this: *CPU, mem: *Memory) !void {
        var zero_page_addr = try this.fetch_byte(mem);
        var value_A = try this.read_byte(zero_page_addr, mem);
        this.registers.A = value_A;
        this.lda_set_status();
    }

    pub fn lda_zpx(this: *CPU, mem: *Memory) !void {
        var zero_page_addr = try this.fetch_byte(mem);
        zero_page_addr += this.registers.X;
        try this.consume_cycles(1);
        var value_A = try this.read_byte(zero_page_addr, mem);
        this.registers.A = value_A;
        this.lda_set_status();
    }
    pub fn ldx_im(this: *CPU, mem: *Memory) !void {
        var value_X = try this.fetch_byte(mem);
        if (value_X == 0) {
            this.flags.Z = 1;
        } else {
            this.flags.Z = 0;
        }
        if ((value_X & 0b10000000) > 0) {
            this.flags.N = 1;
        } else {
            this.flags.N = 0;
        }
        this.registers.X = value_X;
    }

    pub fn ldy_im(this: *CPU, mem: *Memory) !void {
        var value_Y = try this.fetch_byte(mem);
        if (value_Y == 0) {
            this.flags.Z = 1;
        } else {
            this.flags.Z = 0;
        }
        if ((value_Y & 0b10000000) > 0) {
            this.flags.N = 1;
        } else {
            this.flags.N = 0;
        }
        this.registers.Y = value_Y;
    }

    pub fn jsr(this: *CPU, mem: *Memory) !void {
        var sub_addr = this.fetch_word(mem);
        mem.set_word(this.SP, this.PC - 1);
        try this.consume_cycles(2);
        this.PC = sub_addr;
        print("Jumping to: 0x{X}", .{this.PC});
        try this.consume_cycles(1);
        this.SP += 1;
    }

    pub fn execute(this: *CPU, mem: *Memory) CpuError!void {
        while (this.cycles > 0) {
            var byte = try this.fetch_byte(mem);
            print("Byte: 0x{X} ", .{byte});
            var byte_enum = @as(OpCodes, @enumFromInt(byte));
            print("OpCode: {s}\n", .{@tagName(byte_enum)});
            try switch (byte_enum) {
                OpCodes.LDA_IM => this.lda_im(mem),
                OpCodes.LDA_ZP => this.lda_zp(mem),
                OpCodes.LDA_ZPX => this.lda_zpx(mem),
                OpCodes.LDX_IM => this.ldx_im(mem),
                OpCodes.LDY_IM => this.ldy_im(mem),
                OpCodes.JSR => this.ldy_im(mem),
            };
        }
    }

    pub fn build() CPU {
        var registers = Registers{
            .A = 0x0000,
            .X = 0x0000,
            .Y = 0x0000,
        };
        var flags = StatusFlags{
            .N = 0,
            .V = 0,
            .B = 0,
            .D = 0,
            .I = 0,
            .Z = 0,
            .C = 0,
        };
        var log = logger.Logger.build(logger.LogLevel.Info);
        return CPU{ .cycles = 0, .SP = 0x0100, .PC = 0xFFFC, .logger = log, .registers = registers, .flags = flags };
    }
};
