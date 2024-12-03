const std = @import("std");

pub fn main() !void {
    var file = try std.fs.cwd().openFile("/Users/baldur/repositories/advent_of_code/dag1/input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var left_numbers: [1000]i64 = undefined;
    var right_numbers: [1000]i64 = undefined;
    var left_index: usize = 0;
    var right_index: usize = 0;

    var buf: [512]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var tokenizer = std.mem.tokenizeSequence(u8, line, " ");
        const left = try std.fmt.parseInt(i64, tokenizer.next() orelse unreachable, 10);
        const right = try std.fmt.parseInt(i64, tokenizer.next() orelse unreachable, 10);

        left_numbers[left_index] = left;
        right_numbers[right_index] = right;
        left_index += 1;
        right_index += 1;
    }

    std.mem.sort(i64, &left_numbers, {}, std.sort.asc(i64));
    std.mem.sort(i64, &right_numbers, {}, std.sort.asc(i64));

    const stdout = std.io.getStdOut().writer();
    var total_difference: i64 = 0;
    for (0..left_index) |i| {
        if (right_numbers[i] > left_numbers[i]) {
            total_difference += right_numbers[i] - left_numbers[i];
        } else {
            total_difference += left_numbers[i] - right_numbers[i];
        }
    }

    try stdout.print("Total difference: {}\n", .{total_difference});
}
