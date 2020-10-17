usingnamespace @import("commands.zig");
usingnamespace std.sort;

const std = @import("std");
const clap = @import("clap");
const ArgIterator = @import("arg_iterator.zig");

const Order = std.math.Order;
const Allocator = std.mem.Allocator;

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
        Order.eq
    else if (lhs[i] > rhs[i])
        Order.gt
    else if (lhs[i] < rhs[i])
        Order.lt
    else
        Order.eq;
}

fn less_than(context: void, lhs: Command, rhs: Command) bool {
    return compare({}, lhs, rhs) == .lt;
}

const commands = comptime blk: {
    var ret = [_]Command{
        .{ .name = ":", .func = colon },
        .{ .name = "arch", .func = arch },
        .{ .name = "ascii", .func = ascii },
        .{ .name = "base64", .func = base64 },
    };

    sort(Command, &ret, {}, less_than);
    break :blk ret;
};

pub fn main() anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var arena = std.heap.ArenaAllocator.init(&gpa.allocator);

    var it = ArgIterator{
        .inner = std.process.args().inner,
    };

    _ = try it.next();
    const sub = Command{
        .name = (try it.next()) orelse return error.MissingCommand,
        .func = colon,
    };

    const index = binarySearch(Command, sub, &commands, {}, compare) orelse return error.NoCommand;
    try commands[index].func(&arena.allocator, &it);
}
