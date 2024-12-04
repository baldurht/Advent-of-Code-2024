const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    var valid_numbers = std.ArrayList([]i64).init(allocator);
    defer valid_numbers.deinit();

    var file = try std.fs.cwd().openFile("/Users/baldur/repositories/advent_of_code/dag2/input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [512]u8 = undefined;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var tokenizer = std.mem.tokenizeSequence(u8, line, " ");
        var line_numbers = std.ArrayList(i64).init(allocator);
        defer line_numbers.deinit();

        while (tokenizer.next()) |token| {
            const number = try std.fmt.parseInt(i64, token, 10);
            try line_numbers.append(number);
        }
        const slice = try line_numbers.toOwnedSlice();

        var is_valid = true;
        var ascending: ?bool = null;

        for (0..slice.len - 1) |slice_index| {
            const current = slice[slice_index];
            const next = slice[slice_index + 1];
            const diff = next - current;

            if (diff >= 1 and diff <= 3) {
                if (ascending == null or ascending == true) {
                    ascending = true;
                } else {
                    is_valid = false;
                    break;
                }
            } else if (diff >= -3 and diff <= -1) {
                if (ascending == null or ascending == false) {
                    ascending = false;
                } else {
                    is_valid = false;
                    break;
                }
            } else {
                is_valid = false;
                break;
            }
        }

        if (is_valid) {
            try valid_numbers.append(slice);
        }
    }

    const stdout = std.io.getStdOut().writer();
    try stdout.print("Number of safe reports: {}\n", .{valid_numbers.items.len});
}
