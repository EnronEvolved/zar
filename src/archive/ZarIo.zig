const std = @import("std");
const term = std.Io.Terminal;

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

pub const StdIoOpts = struct {
    buf: []u8 = &.{},
    term_conf: ?term.Mode = null
};

pub fn init(
    io: std.Io, 
    cwd: std.Io.Dir, 
    stdout: std.Io.File, 
    stderr: std.Io.File,
    opts: struct {
        stdout: StdIoOpts = .{},
        stderr: StdIoOpts = .{}
}) !ZarIo {

    var stdout_writer = stdout.writer(io, opts.stdout.buf);
    var stderr_writer = stderr.writer(io, opts.stderr.buf);
    const stdout_if = &stdout_writer.interface;
    const stderr_if = &stderr_writer.interface;
    const stdout_config = opts.stdout.term_conf orelse try term.Mode.detect(io, stdout, false, false);
    const stderr_config = opts.stderr.term_conf orelse try term.Mode.detect(io, stderr, false, false);

    return .{
        .io = io,
        .cwd = cwd,
        .stdout = stdout_if,
        .stdout_term = .{
            .writer = stdout_if, 
            .mode = stdout_config
        },
        .stderr = stderr_if,
        .stderr_term = .{
            .writer = stderr_if,
            .mode = stderr_config,
        }
    };
}

pub fn deinit(zar_io: *ZarIo) void {
    zar_io.stdout.flush() catch {};
    zar_io.stderr.flush() catch {};
    zar_io.* = undefined;
}
