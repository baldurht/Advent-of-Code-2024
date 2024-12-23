const std = @import("std");

// Finds occurrences of the word "XMAS" in various directions in a 2D grid.
pub fn findXMAS(grid: [][]const u8) usize {
    var count: usize = 0;
    const rows = grid.len;
    const cols = grid[0].len;

    const directions = [_][2]i32{
        [_]i32{ 0, 1 }, // right
        [_]i32{ 1, 0 }, // down
        [_]i32{ 1, 1 }, // diagonal down-right
        [_]i32{ 1, -1 }, // diagonal down-left
        [_]i32{ 0, -1 }, // left
        [_]i32{ -1, 0 }, // up
        [_]i32{ -1, -1 }, // diagonal up-left
        [_]i32{ -1, 1 }, // diagonal up-right
    };

    const target = "XMAS";

    // Loop through each cell in the grid and search in all directions.
    for (grid, 0..) |row, i| {
        for (row, 0..) |_, j| {
            for (directions) |dir| {
                var valid = true;

                // Check each character of the word "XMAS" in the current direction.
                for (target, 0..) |char, k| {
                    const new_i = @as(i32, @intCast(i)) + dir[0] * @as(i32, @intCast(k));
                    const new_j = @as(i32, @intCast(j)) + dir[1] * @as(i32, @intCast(k));

                    // Stop checking if the position is out of bounds or does not match the target.
                    if (new_i < 0 or new_i >= rows or new_j < 0 or new_j >= cols or
                        grid[@intCast(new_i)][@intCast(new_j)] != char)
                    {
                        valid = false;
                        break;
                    }
                }

                // Increment the count if "XMAS" is found in this direction.
                if (valid) count += 1;
            }
        }
    }

    return count;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Open the input file.
    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    // Load file contents into memory.
    const contents = try file.readToEndAlloc(allocator, 1024 * 1024);
    defer allocator.free(contents);

    // Create and populate a grid with lines from the file.
    var grid = std.ArrayList([]u8).init(allocator);
    defer {
        for (grid.items) |row| {
            allocator.free(row); // Free memory for each row after use.
        }
        grid.deinit();
    }

    var lines = std.mem.splitSequence(u8, contents, "\n");
    while (lines.next()) |line| {
        if (line.len == 0) continue; // Skip empty lines.
        const row = try allocator.alloc(u8, line.len);
        @memcpy(row, line);
        try grid.append(row);
    }

    const result = findXMAS(grid.items);
    const stdout = std.io.getStdOut().writer();
    try stdout.print("{}\n", .{result});
}
