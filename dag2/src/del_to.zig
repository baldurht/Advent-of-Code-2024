const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    var valid_reports = std.ArrayList([]i64).init(allocator);
    defer valid_reports.deinit();

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

        if (isSafe(slice)) {
            try valid_reports.append(slice);
        } else if (try canBeSafeAfterRemoval(slice)) {
            try valid_reports.append(slice);
        }
    }

    const stdout = std.io.getStdOut().writer();
    try stdout.print("Number of safe reports: {}\n", .{valid_reports.items.len});
}

// sjekker hvis den er riktig uten endring
fn isSafe(slice: []const i64) bool {
    var ascending: ?bool = null;

    for (0..slice.len - 1) |i| {
        const diff = slice[i + 1] - slice[i];

        if (diff >= 1 and diff <= 3) {
            if (ascending == null or ascending == true) {
                ascending = true;
            } else {
                return false;
            }
        } else if (diff <= -1 and diff >= -3) {
            if (ascending == null or ascending == false) {
                ascending = false;
            } else {
                return false;
            }
        } else {
            return false;
        }
    }
    return true;
}

// sjekker hvis den er riktig med endring
fn canBeSafeAfterRemoval(slice: []const i64) !bool {
    for (0..slice.len) |index_to_remove| {
        var temp_list = std.ArrayList(i64).init(std.heap.page_allocator);
        defer temp_list.deinit();

        for (0..slice.len) |i| {
            if (i != index_to_remove) {
                try temp_list.append(slice[i]);
            }
        }

        if (isSafe(temp_list.items)) {
            return true;
        }
    }
    return false;
}
