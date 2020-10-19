const Builder = @import("std").build.Builder;
const packages = @import("zig-cache/packages.zig").list;

pub fn build(b: *Builder) void {
    var target = b.standardTargetOptions(.{});
    if (target.abi == null) {
        target.abi = .musl;
    }

    const exe = b.addExecutable("toybox", "src/main.zig");

    // TODO: for some reason we get SIGILL when not building C code with
    // ReleaseFast
    exe.setBuildMode(.ReleaseFast);
    exe.setTarget(target);
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
    "posix/nl.c",
    "posix/mkdir.c",
    "posix/test.c",
    "posix/sleep.c",
    "posix/expand.c",
    "posix/unlink.c",
    "posix/du.c",
    "posix/true.c",
    "posix/chgrp.c",
    "posix/cp.c",
    "posix/who.c",
    "posix/tar.c",
    "posix/chmod.c",
    "posix/ps.c",
    "posix/iconv.c",
    "posix/pwd.c",
    "posix/uudecode.c",
    "posix/file.c",
    "posix/getconf.c",
    "posix/split.c",
    "posix/kill.c",
    "posix/strings.c",
    "posix/ln.c",
    "posix/nice.c",
    "posix/basename.c",
    "posix/rm.c",
    "posix/xargs.c",
    "posix/df.c",
    "posix/wc.c",
    "posix/ulimit.c",
    "posix/renice.c",
    "posix/ls.c",
    "posix/grep.c",
    "posix/uname.c",
    "posix/cpio.c",
    "posix/tail.c",
    "posix/tee.c",
    "posix/sed.c",
    "posix/env.c",
    "posix/sort.c",
    "posix/find.c",
    "posix/false.c",
    "posix/patch.c",
    "posix/cut.c",
    "posix/head.c",
    "posix/logger.c",
    "posix/printf.c",
    "posix/cksum.c",
    "posix/mkfifo.c",
    "posix/echo.c",
    "posix/cmp.c",
    "posix/link.c",
    "posix/id.c",
    "posix/uniq.c",
    "posix/nohup.c",
    "posix/cal.c",
    "posix/date.c",
    "posix/rmdir.c",
    "posix/cat.c",
    "posix/od.c",
    "posix/touch.c",
    "posix/time.c",
    "posix/paste.c",
    "posix/uuencode.c",
    "posix/dirname.c",
    "posix/tty.c",
    "posix/comm.c",
    "net/microcom.c",
    "net/netcat.c",
    "net/tunctl.c",
    "net/rfkill.c",
    "net/ftpget.c",
    "net/ping.c",
    "net/netstat.c",
    "net/ifconfig.c",
    "net/sntp.c",
    "other/ascii.c",
    "other/uuidgen.c",
    "other/rmmod.c",
    "other/nsenter.c",
    "other/w.c",
    "other/count.c",
    "other/modinfo.c",
    "other/hwclock.c",
    "other/mcookie.c",
    "other/which.c",
    "other/help.c",
    "other/partprobe.c",
    "other/reboot.c",
    "other/acpi.c",
    "other/inotifyd.c",
    "other/nbd_client.c",
    "other/usleep.c",
    "other/fsfreeze.c",
    "other/fmt.c",
    "other/pmap.c",
    "other/truncate.c",
    "other/eject.c",
    "other/ionice.c",
    "other/xxd.c",
    "other/pwdx.c",
    "other/mix.c",
    "other/setsid.c",
    "other/losetup.c",
    "other/switch_root.c",
    "other/flock.c",
    "other/vconfig.c",
    "other/fsync.c",
    "other/shred.c",
    "other/devmem.c",
    "other/watch.c",
    "other/lspci.c",
    "other/clear.c",
    "other/lsattr.c",
    "other/mountpoint.c",
    "other/login.c",
    "other/free.c",
    "other/blkdiscard.c",
    "other/setfattr.c",
    "other/reset.c",
    "other/uptime.c",
    "other/sysctl.c",
    "other/yes.c",
    "other/readlink.c",
    "other/readahead.c",
    "other/chvt.c",
    "other/mkpasswd.c",
    "other/swapoff.c",
    "other/pivot_root.c",
    "other/timeout.c",
    "other/insmod.c",
    "other/blkid.c",
    "other/blockdev.c",
    "other/i2ctools.c",
    "other/makedevs.c",
    "other/mkswap.c",
    "other/vmstat.c",
    "other/printenv.c",
    "other/factor.c",
    "other/rtcwake.c",
    "other/chrt.c",
    "other/rev.c",
    "other/tac.c",
    "other/dos2unix.c",
    "other/stat.c",
    "other/lsusb.c",
    "other/freeramdisk.c",
    "other/oneit.c",
    "other/chroot.c",
    "other/fallocate.c",
    "other/base64.c",
    "other/taskset.c",
    "other/swapon.c",
    "other/bzcat.c",
    "other/hexedit.c",
    "other/lsmod.c",
    "lsb/umount.c",
    "lsb/md5sum.c",
    "lsb/mknod.c",
    "lsb/sync.c",
    "lsb/su.c",
    "lsb/mount.c",
    "lsb/passwd.c",
    "lsb/dmesg.c",
    "lsb/mktemp.c",
    "lsb/gzip.c",
    "lsb/killall.c",
    "lsb/pidof.c",
    "lsb/seq.c",
    "lsb/hostname.c",
};
