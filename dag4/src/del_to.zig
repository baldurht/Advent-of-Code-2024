const std = @import("std");

fn symbolAt(grid: [][]const u8, row: i32, col: i32) u8 {
    if (row < 0) return 0;
    if (col < 0) return 0;
    if (row >= grid.len) return 0;
    if (col >= grid[0].len) return 0;
    return grid[@intCast(row)][@intCast(col)];
}

fn is_Good_Diagonal(grid: [][]const u8, rowA: i32, colA: i32, rowB: i32, colB: i32) bool {
    const a = symbolAt(grid, rowA, colA);
    const b = symbolAt(grid, rowB, colB);

    if (a == 'M' and b == 'S') return true;
    if (a == 'S' and b == 'M') return true;

    return false;
}

fn check_XMAS_at(grid: [][]const u8, row: usize, col: usize) bool {
    if (grid[row][col] != 'A') return false;

    const r = @as(i32, @intCast(row));
    const c = @as(i32, @intCast(col));

    // Check both diagonals
    if (!is_Good_Diagonal(grid, r - 1, c - 1, r + 1, c + 1)) return false;
    if (!is_Good_Diagonal(grid, r - 1, c + 1, r + 1, c - 1)) return false;

    return true;
}

pub fn find_XMAS(grid: [][]const u8) usize {
    var count: usize = 0;
    const height = grid.len;
    const width = grid[0].len;

    for (0..height) |row| {
        for (0..width) |col| {
            if (check_XMAS_at(grid, row, col)) {
                count += 1;
            }
        }
    }

    return count;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    const contents = try file.readToEndAlloc(allocator, 1024 * 1024);
    defer allocator.free(contents);

    var grid = std.ArrayList([]u8).init(allocator);
    defer {
        for (grid.items) |row| {
            allocator.free(row);
        }
        grid.deinit();
    }

    var lines = std.mem.splitSequence(u8, contents, "\n");
    while (lines.next()) |line| {
        if (line.len == 0) continue;
        const row = try allocator.alloc(u8, line.len);
        @memcpy(row, line);
        try grid.append(row);
    }

    const result = find_XMAS(grid.items);

    const stdout = std.io.getStdOut().writer();
    try stdout.print("{}\n", .{result});
}
