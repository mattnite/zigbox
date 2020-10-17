const zkg = @import("zkg");

pub const clap = zkg.import.git(
    "https://github.com/Hejsil/zig-clap",
    "zig-master",
    "/clap.zig",
);
