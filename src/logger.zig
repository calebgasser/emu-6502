const std = @import("std");
const log = std.log;
const page_allocator = std.heap.page_allocator;
const ArrayList = std.ArrayList;

pub const LogLevel = enum {
    Info,
    Warn,
    Error,
    Trace,
    Debug,
};

pub const Logger = struct {
    level: LogLevel,
    scopes: ArrayList([]u8),

    pub fn build(lvl: LogLevel) Logger {
        return Logger{
            .level = lvl,
            .scopes = ArrayList([]u8).init(page_allocator),
        };
    }
};
