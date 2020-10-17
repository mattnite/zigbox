const std = @import("std");

inner: std.process.ArgIteratorPosix,

pub const Error = error{};

pub fn next(self: *@This()) Error!?[]const u8 {
    return self.inner.next();
}
