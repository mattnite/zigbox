usingnamespace @import("commands.zig");
usingnamespace std.sort;

const std = @import("std");
const clap = @import("clap");
const ArgIterator = @import("arg_iterator.zig");

const c = @cImport({
    @cInclude("toys.h");
});

const Order = std.math.Order;
const Allocator = std.mem.Allocator;
const stderr = std.io.getStdErr().writer();

const Command = struct {
    name: []const u8,
    func: fn (*Allocator, *ArgIterator) anyerror!void,
};

fn compare(context: void, lhs_comm: Command, rhs_comm: Command) Order {
    const lhs = lhs_comm.name;
    const rhs = rhs_comm.name;

    var i: usize = 0;
    const n = std.math.min(lhs.len, rhs.len);
    while (i < n and lhs[i] == rhs[i]) : (i += 1) {}
    return if (i == n)
        std.math.order(lhs.len, rhs.len)
    else if (lhs[i] > rhs[i])
        Order.gt
    else if (lhs[i] < rhs[i])
        Order.lt
    else
        Order.eq;
}

fn lessThan(context: void, lhs: Command, rhs: Command) bool {
    return compare({}, lhs, rhs) == .lt;
}

const commands = comptime blk: {
    var ret = [_]Command{
        .{ .name = "arch", .func = arch },
        .{ .name = "ascii", .func = ascii },
        .{ .name = "base64", .func = base64 },
    };

    sort(Command, &ret, {}, lessThan);
    break :blk ret;
};

extern fn tb_main(argc: c_int, argv: [*c][*c]u8) c_int;

pub fn main() anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var arena = std.heap.ArenaAllocator.init(&gpa.allocator);

    var it = ArgIterator{
        .inner = std.process.args().inner,
    };

    _ = try it.next();
    const sub = Command{
        .name = (try it.next()) orelse return error.MissingCommand,
        .func = undefined,
    };

    if (binarySearch(Command, sub, &commands, {}, compare)) |index| {
        try commands[index].func(&arena.allocator, &it);
    } else {
        _ = tb_main(@intCast(c_int, std.os.argv.len), @ptrCast([*c][*c]u8, std.os.argv.ptr));
    }
}
