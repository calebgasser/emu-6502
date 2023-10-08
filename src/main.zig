const CPU = @import("cpu.zig").CPU;
const Memory = @import("memory.zig").Memory;
const OpCodes = @import("opcodes.zig").OpCodes;

pub fn main() !void {
    var mem = Memory.init();
    var cpu = CPU.init();
    mem.set_byte(0, @intFromEnum(OpCodes.LDA_IM));
    mem.set_byte(1, 10);
    cpu.add_cycles(2);
    try cpu.execute(&mem);
    mem.print_state(0, 10);
    cpu.print_state();
    mem.set_byte(2, @intFromEnum(OpCodes.LDA_IM));
    mem.set_byte(3, 100);
    cpu.add_cycles(2);
    try cpu.execute(&mem);
    mem.print_state(0, 10);
    cpu.print_state();
}
