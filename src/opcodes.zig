pub const OpCodes = enum(u8) {
    LDA_IM = 0xA9, // Load accumulator, immediate mode
    LDX_IM = 0xA2, // Load X, immediate mode
    LDY_IM = 0xA0, // Load Y, immediate mode
};
