const std = @import("std");

var stdout_mutex = std.Thread.Mutex{};

pub fn print(comptime fmt: []const u8, args: anytype) void {
    stdout_mutex.lock();
    defer stdout_mutex.unlock();
    const stdout = std.io.getStdOut().writer();
    nosuspend stdout.print(fmt, args) catch return;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFileZ("/dev/random", .{});
    defer file.close();

    var buf = try allocator.alloc(u8, 16);
    defer allocator.free(buf);

    _ = try file.read(buf);

    // Set bit 6 to 0
    buf[8] &= ~(@as(u8, 1) << 6);
    // Set bit 7 to 1
    buf[8] |= 1 << 7;

    // Set version
    buf[6] &= ~(@as(u8, 1) << 4);
    buf[6] &= ~(@as(u8, 1) << 5);
    buf[6] |= 1 << 6;
    buf[6] &= ~(@as(u8, 1) << 7);

    print("{}-{}-{}-{}-{}", .{
        std.fmt.fmtSliceHexLower(buf[0..4]),
        std.fmt.fmtSliceHexLower(buf[4..6]),
        std.fmt.fmtSliceHexLower(buf[6..8]),
        std.fmt.fmtSliceHexLower(buf[8..10]),
        std.fmt.fmtSliceHexLower(buf[10..16]),
    });
}
