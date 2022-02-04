const cmds = @import("commands.zig");

const std = @import("std");
const clap = @import("clap");
const ArgIterator = @import("arg_iterator.zig");

const c = @cImport({
    @cInclude("toys.h");
    @cInclude("main.h");
});

const Order = std.math.Order;
const Allocator = std.mem.Allocator;
const stderr = std.io.getStdErr().writer();

const Command = struct {
    name: []const u8,
    func: fn (Allocator, *std.process.ArgIterator) anyerror!void,
};

fn compare(_: void, lhs_comm: Command, rhs_comm: Command) Order {
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

fn lessThan(_: void, lhs: Command, rhs: Command) bool {
    return compare({}, lhs, rhs) == .lt;
}

const commands = blk: {
    var ret = [_]Command{
        .{ .name = "arch", .func = cmds.arch },
        .{ .name = "ascii", .func = cmds.ascii },
        .{ .name = "base64", .func = cmds.base64 },
        .{ .name = "uname", .func = cmds.uname },
    };

    std.sort.sort(Command, &ret, {}, lessThan);
    break :blk ret;
};

pub fn main() anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var it = try std.process.ArgIterator.initWithAllocator(gpa.allocator());
    defer it.deinit();

    // skip process name
    _ = it.next();

    const sub = Command{
        .name = (it.next()) orelse {
            try stderr.writeAll("no subcommand selected, choose one of the following:\n\n");
            for (commands) |cmd|
                try stderr.print("    {s}\n", .{cmd.name});

            try stderr.writeByte('\n');
            return error.MissingCommand;
        },
        .func = undefined,
    };

    if (std.sort.binarySearch(Command, sub, &commands, {}, compare)) |index| {
        try commands[index].func(gpa.allocator(), &it);
    } else {
        _ = c.tb_main(@intCast(c_int, std.os.argv.len), @ptrCast([*:null]?[*:0]u8, std.os.argv));
    }
}
