const clap = @import("clap");
const std = @import("std");
const ArgIterator = @import("arg_iterator.zig");

const stdout = std.io.getStdOut().writer();
const stderr = std.io.getStdOut().writer();
const stdin = std.io.getStdIn().reader();
const Allocator = std.mem.Allocator;

pub fn arch(allocator: Allocator, it: *std.process.ArgIterator) !void {
    _ = allocator;
    const params = comptime [_]clap.Param(clap.Help){
        clap.parseParam("-h, --help Display this help and exit") catch unreachable,
    };

    var diag = clap.Diagnostic{};
    var args = clap.parseEx(clap.Help, &params, it, .{ .diagnostic = &diag }) catch |err| {
        // Report useful error and exit
        diag.report(stderr, err) catch {};
        return err;
    };
    defer args.deinit();

    if (args.flag("--help")) {
        try stdout.print("Usage: arch ", .{});
        try clap.usage(stdout, &params);
        try stdout.print("\n\nPrint machine (hardware) name, same as uname -m.\n\n", .{});
        try clap.help(stdout, &params);
        return;
    }

    try stdout.print("{s}\n", .{std.os.uname().machine});
}

pub fn ascii(allocator: Allocator, it: *std.process.ArgIterator) !void {
    _ = allocator;
    _ = it;
    try stdout.writeAll(
        \\Dec Hex    Dec Hex    Dec Hex  Dec Hex  Dec Hex  Dec Hex   Dec Hex   Dec Hex
        \\  0 00 NUL  16 10 DLE  32 20    48 30 0  64 40 @  80 50 P   96 60 `  112 70 p
        \\  1 01 SOH  17 11 DC1  33 21 !  49 31 1  65 41 A  81 51 Q   97 61 a  113 71 q
        \\  2 02 STX  18 12 DC2  34 22 "  50 32 2  66 42 B  82 52 R   98 62 b  114 72 r
        \\  3 03 ETX  19 13 DC3  35 23 #  51 33 3  67 43 C  83 53 S   99 63 c  115 73 s
        \\  4 04 EOT  20 14 DC4  36 24 $  52 34 4  68 44 D  84 54 T  100 64 d  116 74 t
        \\  5 05 ENQ  21 15 NAK  37 25 %  53 35 5  69 45 E  85 55 U  101 65 e  117 75 u
        \\  6 06 ACK  22 16 SYN  38 26 &  54 36 6  70 46 F  86 56 V  102 66 f  118 76 v
        \\  7 07 BEL  23 17 ETB  39 27 '  55 37 7  71 47 G  87 57 W  103 67 g  119 77 w
        \\  8 08 BS   24 18 CAN  40 28 (  56 38 8  72 48 H  88 58 X  104 68 h  120 78 x
        \\  9 09 HT   25 19 EM   41 29 )  57 39 9  73 49 I  89 59 Y  105 69 i  121 79 y
        \\ 10 0A LF   26 1A SUB  42 2A *  58 3A :  74 4A J  90 5A Z  106 6A j  122 7A z
        \\ 11 0B VT   27 1B ESC  43 2B +  59 3B ;  75 4B K  91 5B [  107 6B k  123 7B {
        \\ 12 0C FF   28 1C FS   44 2C ,  60 3C <  76 4C L  92 5C \  108 6C l  124 7C |
        \\ 13 0D CR   29 1D GS   45 2D -  61 3D =  77 4D M  93 5D ]  109 6D m  125 7D }
        \\ 14 0E SO   30 1E RS   46 2E .  62 3E >  78 4E N  94 5E ^  110 6E n  126 7E ~
        \\ 15 0F SI   31 1F US   47 2F /  63 3F ?  79 4F O  95 5F _  111 6F o  127 7F DEL
        \\
    );
}

pub fn base64(allocator: Allocator, it: *std.process.ArgIterator) !void {
    _ = allocator;
    const params = comptime [_]clap.Param(clap.Help){
        clap.parseParam("-h            Display this help and exit") catch unreachable,
        clap.parseParam("-d            Decode") catch unreachable,
        clap.parseParam("-i            Ignore non-alphanumeric characters") catch unreachable,
        clap.parseParam("-w <COLUMNS>  Wrap output at COLUMS (default 76, or 0 for nowrap)") catch unreachable,
    };

    var diag = clap.Diagnostic{};
    var args = clap.parseEx(clap.Help, &params, it, .{ .diagnostic = &diag }) catch |err| {
        // Report useful error and exit
        diag.report(stderr, err) catch {};
        return err;
    };
    defer args.deinit();

    var buf_plain: [3 * std.mem.page_size]u8 = undefined;
    var buf_encoded: [4 * std.mem.page_size]u8 = undefined;
    const encoding = !args.flag("-d");

    if (encoding) {
        const Encoder = std.base64.standard.Encoder;
        const n = try stdin.read(&buf_plain);
        const enc_n = Encoder.calcSize(n);
        const encoded = Encoder.encode(buf_encoded[0..enc_n], buf_plain[0..n]);

        try stdout.print("{s}\n", .{encoded});

        return error.Todo;
    } else {
        return error.Todo;
    }
}

pub fn uname(allocator: Allocator, it: *std.process.ArgIterator) !void {
    _ = allocator;
    @setEvalBranchQuota(1500);
    const params = comptime [_]clap.Param(clap.Help){
        clap.parseParam("-h, --help  Display this help and exit") catch unreachable,
        clap.parseParam("-s          System name") catch unreachable,
        clap.parseParam("-n          Network (domain) name") catch unreachable,
        clap.parseParam("-r          Kernel Release number") catch unreachable,
        clap.parseParam("-v          Kernel Version") catch unreachable,
        clap.parseParam("-m          Machine (hardware) name") catch unreachable,
        clap.parseParam("-a          All of the above") catch unreachable,
    };

    var diag = clap.Diagnostic{};
    var args = clap.parseEx(clap.Help, &params, it, .{ .diagnostic = &diag }) catch |err| {
        // Report useful error and exit
        diag.report(stderr, err) catch {};
        return err;
    };
    defer args.deinit();

    if (args.flag("--help")) {
        try stdout.print("Usage: arch ", .{});
        try clap.usage(stdout, &params);
        try stdout.print("\n\nPrint system information.\n\n", .{});
        try clap.help(stdout, &params);
        return;
    }

    const name = std.os.uname();
    var printed = false;

    // Print the system name by default
    if (args.flag("-s") or args.flag("-a") or (!args.flag("-r") and !args.flag("-n") and !args.flag("-v") and !args.flag("-m"))) {
        try stdout.print("{s}", .{name.sysname});
        printed = true;
    }

    if (args.flag("-n") or args.flag("-a")) {
        if (printed)
            try stdout.print(" ", .{});
        try stdout.print("{s}", .{name.nodename});
        printed = true;
    }

    if (args.flag("-r") or args.flag("-a")) {
        if (printed)
            try stdout.print(" ", .{});
        try stdout.print("{s}", .{name.release});
        printed = true;
    }

    if (args.flag("-v") or args.flag("-a")) {
        if (printed)
            try stdout.print(" ", .{});
        try stdout.print("{s}", .{name.version});
        printed = true;
    }

    if (args.flag("-m") or args.flag("-a")) {
        if (printed)
            try stdout.print(" ", .{});
        try stdout.print("{s}", .{name.machine});
        printed = true;
    }

    try stdout.print("\n", .{});
}
