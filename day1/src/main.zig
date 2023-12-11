const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const input = try readFile(allocator, "day1.txt");

    var result: u64 = 0;
    var input_iter = std.mem.split(u8, input, "\n");
    while (input_iter.next()) |line| {
        if (line.len > 0)
            result += try extractDigit(allocator, line);
    }

    std.debug.print("Result: {}", .{result});
}

fn readFile(allocator: std.mem.Allocator, file: []const u8) ![]u8 {
    const file_handle = try std.fs.cwd().openFile(file, .{});
    defer file_handle.close();

    const file_size = try file_handle.getEndPos();

    var read_buf = try file_handle.readToEndAlloc(allocator, file_size);

    var new_buf = std.ArrayList(u8).init(allocator);

    var buf_iter = std.mem.window(u8, read_buf, 1, 1);
    while (buf_iter.next()) |item| {
        if (item[0] != '\r') {
            try new_buf.append(item[0]);
        }
    }

    return new_buf.items;
}

pub fn extractDigit(allocator: Allocator, str: []const u8) !u64 {
    var digit_chars: std.ArrayList(u8) = std.ArrayList(u8).init(allocator);
    var chars_iter = std.mem.window(u8, str, 1, 1);
    while (chars_iter.next()) |ch| {
        const char = ch[0];
        if (char >= 48 and char <= 57) {
            try digit_chars.append(char);
        }
    }

    const tens = try std.fmt.parseInt(u64, digit_chars.items[0..1], 10) * 10;
    const ones = try std.fmt.parseInt(u64, digit_chars.items[digit_chars.items.len - 1 .. digit_chars.items.len], 10);

    return tens + ones;
}

pub fn extractDigits(allocator: Allocator, str: []const []const u8) ![]const u64 {
    var digits = std.ArrayList(u64).init(allocator);
    for (str) |line| {
        try digits.append(try extractDigit(allocator, line));
    }

    return digits.items;
}

test "can parse line" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    try std.testing.expectEqual(try extractDigit(allocator, "pqr3stu8vwx"), 38);
}

test "can parse multiple lines" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const result = try extractDigits(allocator, &[_][]const u8{
        "1abc2",
        "pqr3stu8vwx",
        "a1b2c3d4e5f",
        "treb7uchet",
    });

    try std.testing.expectEqual(result[0], 12);
    try std.testing.expectEqual(result[1], 38);
    try std.testing.expectEqual(result[2], 15);
    try std.testing.expectEqual(result[3], 77);
}
