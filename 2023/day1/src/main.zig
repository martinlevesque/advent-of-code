const std = @import("std");

fn find_left_digit(str: []const u8) ?i32 {
    // loop i for i in 0 .. str.len

    var i: usize = 0;
    while (i < str.len) : (i += 1) {
        if (str[i] >= '0' and str[i] <= '9') {
            // convert str[i] to i32
            return str[i] - '0';
        }
    }

    return null;
}


pub fn main() !void {
    var file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();
    std.log.info("hello.", .{});

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [100000]u8 = undefined;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
       // do something with line...
       std.log.info("line = {s}", .{line});
       var left_index = find_left_digit(line);

       if (left_index != null) {
           std.log.info("left_index = {d}", .{left_index.?});
       }
    }
}

test "simple test" {
}
