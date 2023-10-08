const CPU = @import("cpu.zig").CPU;
const Memory = @import("memory.zig").Memory;
const OpCodes = @import("opcodes.zig").OpCodes;

pub fn main() !void {
    var mem = Memory.build();
    var cpu = CPU.build();

    mem.set_byte(0xFFFC, @intFromEnum(OpCodes.JSR));
    mem.set_byte(0xFFFD, 0xEF);
    mem.set_byte(0xFFFE, 0xEF);
    mem.set_byte(0x00EF, @intFromEnum(OpCodes.LDA_IM));
    mem.set_byte(0x00EE, 0x84);
    mem.print_state(0xFFEE, 0xFFFF);
    cpu.add_cycles(8);
    try cpu.execute(&mem);

    mem.print_state(0, 10);
    cpu.print_state();
}
