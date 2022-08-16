const std = @import("std");

var stdout_mutex = std.Thread.Mutex{};

pub fn print(comptime fmt: []const u8, args: anytype) void {
    stdout_mutex.lock();
    defer stdout_mutex.unlock();
    const stdout = std.io.getStdOut().writer();
    nosuspend stdout.print(fmt, args) catch return;
}

pub fn main() !void {
    if (std.os.argv.len < 2) {
        std.debug.print("Expected file name to interpret", .{});
        return;
    }

    const allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFileZ(std.os.argv[1], .{});
    defer file.close();

    const file_size = try file.getEndPos();
    var prog = try allocator.alloc(u8, file_size);
    defer allocator.free(prog);

    _ = try file.read(prog);

    var data_stack = std.mem.zeroes([30_000]u8);
    var data_pointer: usize = 0;

    var instr_stack = std.ArrayList(usize).init(allocator);
    defer instr_stack.deinit();

    var instr_pointer: usize = 0;

    var stdin_stream = std.io.bufferedReader(std.io.getStdIn().reader());

    while (instr_pointer < prog.len) {
        switch (prog[instr_pointer]) {
            '>' => {
                data_pointer = data_pointer + 1;
            },
            '<' => {
                data_pointer = data_pointer - 1;
            },
            '+' => {
                data_stack[data_pointer] = data_stack[data_pointer] + 1;
            },
            '-' => {
                data_stack[data_pointer] = data_stack[data_pointer] - 1;
            },
            '.' => {
                print("{c}", .{data_stack[data_pointer]});
            },
            ',' => {
                data_stack[data_pointer] = try stdin_stream.reader().readByte();
            },
            '[' => {
                var stack: i64 = 1;
                var end = instr_pointer + 1;
                while (stack != 0) {
                    switch (prog[end]) {
                        '[' => {
                            stack = stack + 1;
                        },
                        ']' => {
                            stack = stack - 1;
                        },
                        else => {},
                    }

                    end = end + 1;
                }

                if (data_stack[data_pointer] == 0) {
                    instr_pointer = end;
                } else {
                    try instr_stack.append(instr_pointer);
                }
            },
            ']' => {
                const new_pointer = instr_stack.pop() - 1;
                if (data_stack[data_pointer] != 0) {
                    instr_pointer = new_pointer;
                }
            },
            else => {},
        }

        instr_pointer = instr_pointer + 1;
    }
}
