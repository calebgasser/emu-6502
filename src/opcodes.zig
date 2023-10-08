pub const OpCodes = enum(u8) {
    LDA_IM = 0xA9, // Load accumulator, immediate mode
    LDA_ZP = 0xA5, // Load accumulator, zero page
    LDA_ZPX = 0xB5, // Load accumulator, zero page
    LDX_IM = 0xA2, // Load X, immediate mode
    LDY_IM = 0xA0, // Load Y, immediate mode
    JSR = 0x20, // Jump to subroutine
};
