const std = @import("std");

/// Main function that reads input file and processes instructions
pub fn main() !void {
    // Initialize memory allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Open and read the input file
    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();
    const content = try file.readToEndAlloc(allocator, file_size);
    defer allocator.free(content);

    // Initialize variables for processing
    var sum: u64 = 0; // Running sum of valid multiplication results
    var i: usize = 0; // Current position in input
    var enabled = true; // Flag to track if multiplications are enabled

    // Process input character by character
    while (i < content.len) {
        if (tryParseMul(content[i..])) |result| {
            if (enabled) {
                sum += result.product;
            }
            i += result.len;
        } else if (tryParseControl(content[i..])) |result| {
            enabled = result.enable;
            i += result.len;
        } else {
            i += 1;
        }
    }

    // Output final result
    const stdout = std.io.getStdOut().writer();
    try stdout.print("{d}\n", .{sum});
}

/// Struct to hold multiplication instruction results
const MulResult = struct {
    product: u64, // Result of multiplication
    len: usize, // Length of parsed instruction
};

/// Struct to hold control instruction results
const ControlResult = struct {
    enable: bool, // Whether to enable or disable multiplication
    len: usize, // Length of parsed instruction
};

/// Attempts to parse a do() or don't() control instruction
fn tryParseControl(input: []const u8) ?ControlResult {
    const do_str = "do()";
    const dont_str = "don't()";

    // Check for do() instruction
    if (input.len >= do_str.len and std.mem.eql(u8, input[0..do_str.len], do_str)) {
        return ControlResult{ .enable = true, .len = do_str.len };
    }

    // Check for don't() instruction
    if (input.len >= dont_str.len and std.mem.eql(u8, input[0..dont_str.len], dont_str)) {
        return ControlResult{ .enable = false, .len = dont_str.len };
    }

    return null;
}

/// Attempts to parse a mul(X,Y) instruction
fn tryParseMul(input: []const u8) ?MulResult {
    // Check minimum length for mul(X,Y)
    if (input.len < 8) return null;
    if (!std.mem.eql(u8, input[0..4], "mul(")) return null;

    var pos: usize = 4;
    var first_num: u64 = 0; // First number in multiplication
    var second_num: u64 = 0; // Second number in multiplication
    var parsing_first = true; // Flag to track which number we're parsing
    var found_comma = false; // Flag to ensure proper format

    while (pos < input.len) {
        const c = input[pos];

        if (c == ')') {
            // Ensure we've found a comma and finished parsing both numbers
            if (!found_comma or parsing_first) return null;
            return MulResult{
                .product = first_num * second_num,
                .len = pos + 1,
            };
        } else if (c == ',') {
            // Handle comma between numbers
            if (found_comma or parsing_first == false) return null;
            found_comma = true;
            parsing_first = false;
            pos += 1;
            continue;
        } else if (std.ascii.isDigit(c)) {
            // Parse digits, ensuring numbers are 1-3 digits long
            const num = c - '0';
            if (parsing_first) {
                if (first_num > 99) return null;
                first_num = first_num * 10 + num;
            } else {
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
