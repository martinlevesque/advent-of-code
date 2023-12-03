const std = @import("std");

fn make_hash_digits_mappings(allocator: std.mem.Allocator) !std.StringHashMap(i32) {
    var my_hash_map = std.StringHashMap(i32).init(allocator);

    try my_hash_map.put("0", 0);
    try my_hash_map.put("1", 1);
    try my_hash_map.put("2", 2);
    try my_hash_map.put("3", 3);
    try my_hash_map.put("4", 4);
    try my_hash_map.put("5", 5);
    try my_hash_map.put("6", 6);
    try my_hash_map.put("7", 7);
    try my_hash_map.put("8", 8);
    try my_hash_map.put("9", 9);

    try my_hash_map.put("zero", 0);
    try my_hash_map.put("one", 1);
    try my_hash_map.put("two", 2);
    try my_hash_map.put("three", 3);
    try my_hash_map.put("four", 4);
    try my_hash_map.put("five", 5);
    try my_hash_map.put("six", 6);
    try my_hash_map.put("seven", 7);
    try my_hash_map.put("eight", 8);
    try my_hash_map.put("nine", 9);

    return my_hash_map;
}

fn find_left_digit(str: []const u8, hash_digits: std.StringHashMap(i32)) ?i32 {
    var i: usize = 0;
    while (i < str.len) : (i += 1) {
        var iter = hash_digits.iterator();

        while (iter.next()) |it| {
            const current_mapping_key = it.key_ptr.*;

            if (i + current_mapping_key.len <= str.len) {
                const slice_from_i = str[i..i + current_mapping_key.len];

                if (std.mem.eql(u8, current_mapping_key, slice_from_i)) {
                    return it.value_ptr.*;
                }
            }
        }
    }

    return null;
}

fn find_right_digit(str: []const  u8, hash_digits: std.StringHashMap(i32)) ?i32 {
    var i: usize = str.len-1;
    while (i >= 0) : (i -= 1) {
        var iter = hash_digits.iterator();

        while (iter.next()) |it| {
            const current_mapping_key = it.key_ptr.*;

            if (@as(i32, @intCast(i)) + 1 - @as(i32, @intCast(current_mapping_key.len)) >= 0) {
                const slice_from_i = str[(i + 1 - current_mapping_key.len)..i+1];

                if (std.mem.eql(u8, current_mapping_key, slice_from_i)) {
                    return it.value_ptr.*;
                }
            }
        }
    }

    return null;
}

fn calibration_value(left_digit: i32, right_digit: i32) i32 {
    return left_digit * 10 + right_digit;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var digits_mappings = try make_hash_digits_mappings(allocator);
    defer digits_mappings.deinit();

    var file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [100000]u8 = undefined;
    var sum_calibrations: i32 = 0;


    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
       // do something with line...
       var left_digit = find_left_digit(line, digits_mappings);
       var right_digit = find_right_digit(line, digits_mappings);

       if (left_digit == null or right_digit == null) {
           continue;
       }

       var current_calibration_value = calibration_value(left_digit.?, right_digit.?);
       sum_calibrations += current_calibration_value;
    }

    std.debug.print("sum_calibrations = {d}", .{sum_calibrations});
}

test "find_left_digit happy path" {
    var input = "ab1c13ds";
    const allocator = std.testing.allocator;
    var hash_digits = try make_hash_digits_mappings(allocator);
    defer hash_digits.deinit();

    var result = find_left_digit(input, hash_digits);
    try std.testing.expect(result == 1);
}

test "find_left_digit happy with letters" {
    const allocator = std.testing.allocator;
    var hash_digits = try make_hash_digits_mappings(allocator);
    defer hash_digits.deinit();
    var input = "abcone2threexyz";

    var result = find_left_digit(input, hash_digits);
    try std.testing.expect(result == 1);
}

test "find_left_digit happy with letters end" {
    const allocator = std.testing.allocator;
    var hash_digits = try make_hash_digits_mappings(allocator);
    defer hash_digits.deinit();
    var input = "abcthree";

    var result = find_left_digit(input, hash_digits);
    try std.testing.expect(result == 3);
}


test "find_left_digit left side" {
    const allocator = std.testing.allocator;
    var hash_digits = try make_hash_digits_mappings(allocator);
    defer hash_digits.deinit();
    var input = "3bcds";

    var result = find_left_digit(input, hash_digits);
    try std.testing.expect(result == 3);
}

test "find_left_digit right side" {
    const allocator = std.testing.allocator;
    var hash_digits = try make_hash_digits_mappings(allocator);
    defer hash_digits.deinit();
    var input = "bcds4";

    var result = find_left_digit(input, hash_digits);
    try std.testing.expect(result == 4);
}

test "find_left_digit happy with letters begin" {
    const allocator = std.testing.allocator;
    var hash_digits = try make_hash_digits_mappings(allocator);
    defer hash_digits.deinit();
    var input = "nineabcthree";

    var result = find_left_digit(input, hash_digits);
    try std.testing.expect(result == 9);
}

test "find_right_digit happy path" {
    const allocator = std.testing.allocator;
    var hash_digits = try make_hash_digits_mappings(allocator);
    defer hash_digits.deinit();
    var input = "ab1c13ds";

    var result = find_right_digit(input, hash_digits);
    try std.testing.expect(result == 3);
}

test "find_right_digit with letters end" {
    const allocator = std.testing.allocator;
    var hash_digits = try make_hash_digits_mappings(allocator);
    defer hash_digits.deinit();
    var input = "ab1c13dsnine";

    var result = find_right_digit(input, hash_digits);
    try std.testing.expect(result == 9);
}

test "find_right_digit with letters begin" {
    const allocator = std.testing.allocator;
    var hash_digits = try make_hash_digits_mappings(allocator);
    defer hash_digits.deinit();
    var input = "threeabcds";

    var result = find_right_digit(input, hash_digits);
    try std.testing.expect(result == 3);
}

test "find_right_digit left only" {
    const allocator = std.testing.allocator;
    var hash_digits = try make_hash_digits_mappings(allocator);
    defer hash_digits.deinit();
    var input = "4bcds";

    var result = find_right_digit(input, hash_digits);
    try std.testing.expect(result == 4);
}

test "find_right_digit right only" {
    const allocator = std.testing.allocator;
    var hash_digits = try make_hash_digits_mappings(allocator);
    defer hash_digits.deinit();
    var input = "bcds1";

    var result = find_right_digit(input, hash_digits);
    try std.testing.expect(result == 1);
}

test "calibration_value" {
    var result = calibration_value(1, 2);
    try std.testing.expect(result == 12);
}
