const Builder = @import("std").build.Builder;
const packages = @import("zig-cache/packages.zig").list;

pub fn build(b: *Builder) void {
    var target = b.standardTargetOptions(.{});
    if (target.abi == null) {
        target.abi = .musl;
    }

    const mode = b.standardReleaseOptions();
    const exe = b.addExecutable("toybox", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.single_threaded = true;
    exe.addIncludeDir(".");
    exe.addIncludeDir("lib");
    for (packages) |pkg| {
        exe.addPackage(pkg);
    }

    exe.addCSourceFile("main.c", &[_][]const u8{});
    inline for (lib_srcs) |src| {
        exe.addCSourceFile("lib/" ++ src, &[_][]const u8{});
    }

    inline for (c_srcs) |src| {
        exe.addCSourceFile("toys/" ++ src, &[_][]const u8{});
    }

    exe.setOutputDir(".");
    exe.linkLibC();
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}

const lib_srcs = [_][]const u8{
    "args.c",
    "commas.c",
    "deflate.c",
    "dirtree.c",
    "env.c",
    "help.c",
    "lib.c",
    "linestack.c",
    "llist.c",
    "net.c",
    "password.c",
    "portability.c",
    "tty.c",
    "xwrap.c",
};

const c_srcs = [_][]const u8{
    "posix/basename.c",
};
