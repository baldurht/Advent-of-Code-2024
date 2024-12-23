const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Open and read the input file
    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();
    const content = try file.readToEndAlloc(allocator, file_size);
    defer allocator.free(content);

    var sum: u64 = 0;
    var i: usize = 0;
    while (i < content.len) {
        if (tryParseMul(content[i..])) |result| {
            sum += result.product;
            i += result.len;
        } else {
            i += 1;
        }
    }

    const stdout = std.io.getStdOut().writer();
    try stdout.print("{d}\n", .{sum});
}

const MulResult = struct {
    product: u64,
    len: usize,
};

fn tryParseMul(input: []const u8) ?MulResult {
    // Check if we have enough characters for a minimal mul(X,Y) instruction
    if (input.len < 8) return null;

    // Check for "mul("
    if (!std.mem.eql(u8, input[0..4], "mul(")) return null;

    var pos: usize = 4;
    var first_num: u64 = 0;
    var second_num: u64 = 0;
    var parsing_first = true;
    var found_comma = false;

    while (pos < input.len) {
        const c = input[pos];

        // Handle closing parenthesis
        if (c == ')') {
            if (!found_comma or parsing_first) return null;
            return MulResult{
                .product = first_num * second_num,
                .len = pos + 1,
            };
        }
        // Handle comma
        else if (c == ',') {
            if (found_comma or parsing_first == false) return null;
            found_comma = true;
            parsing_first = false;
            pos += 1;
            continue;
        }
        // Handle digits
        else if (std.ascii.isDigit(c)) {
            const num = c - '0';
            if (parsing_first) {
                // Check for numbers longer than 3 digits
                if (first_num > 99) return null;
                first_num = first_num * 10 + num;
            } else {
                // Check for numbers longer than 3 digits
                if (second_num > 99) return null;
                second_num = second_num * 10 + num;
            }
        } else {
            return null;
        }
        pos += 1;
    }

    return null;
}
