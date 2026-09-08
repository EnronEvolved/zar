const std = @import("std");

const ZarIo = @This();

io: std.Io,
cwd: std.Io.Dir,
stdout: *std.Io.Writer,
stdout_term: std.Io.Terminal,
stderr: *std.Io.Writer,
stderr_term: std.Io.Terminal,

pub fn printError(zar_io: *const ZarIo, comptime format: []const u8, args: anytype) void {
    zar_io.stderr.print("zar: ", .{}) catch {};
    zar_io.stderr_term.setColor(.red) catch {};
    zar_io.stderr_term.setColor(.bold) catch {};
    zar_io.stderr.print("error: ", .{}) catch {};
    zar_io.stderr_term.setColor(.reset) catch {};
    zar_io.stderr.print(format, args) catch {};
    zar_io.stderr.print("\n", .{}) catch {};
}
