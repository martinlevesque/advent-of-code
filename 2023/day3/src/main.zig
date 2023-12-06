const std = @import("std");

pub const Line = struct {
    line: []const u8,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, param_line: []const u8) !Line {
        // alloc 
        // copy line
        var cloned_line = try allocator.alloc(u8, param_line.len);
        std.mem.copy(u8, cloned_line, param_line);

        return Line{ .allocator = allocator, .line = cloned_line };
    }

    pub fn deinit(self: *Line) void {
        self.allocator.free(self.line);
    }
};

pub const Engine = struct {
    lines: std.ArrayList(Line),
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) !Engine {
        return Engine{ .allocator = allocator, .lines = std.ArrayList(Line).init(allocator) };
    }

    pub fn append(self: *Engine, line: Line) !void {
        try self.lines.append(line);
    }

    fn is_number(c: u8) bool {
        return c >= '0' and c <= '9';
    }

    pub fn sum_adjacent_numbers(self: *Engine) i32 {
        var sum: i32 = 0;

        for (self.lines.items, 0..) |*line, index_line| {
            std.log.info("mmline = {s} @ {d}\n", .{line.line, index_line});

            var begin_n: ?usize = null;
            var end_n: ?usize = null;

            for (line.line, 0..) |c, index_char| {
                if (Engine.is_number(c) and begin_n == null) {
                    begin_n = index_char;
                } else {
                    if ((Engine.is_number(c) == false) and begin_n != null) {
                        end_n = index_char - 1;

                        // var number_s = line.line[begin_n.?..end_n.?+1];

                        var is_adj = self.has_adjacent_symbol(index_line, begin_n.?, end_n.?);

                        if (is_adj) {
                            var number_s = line.line[begin_n.?..end_n.?+1];
                            var number = std.fmt.parseInt(i32, number_s, 10) catch {
                                std.log.info("failed to parse int in {s}\n", .{line.line});
                                return 0;
                            };
                            std.log.info("++++ adding {d} ++++\n", .{number});
                            sum += number;
                            std.log.info("now sum is {d}\n", .{sum});
                        }

                        begin_n = null;
                        end_n = null;
                    }
                }
            }
        }

        return sum;
    }

    fn is_symbol(c: u8) bool {
        //return Engine.is_number(c) == false and c != '.';
        return c != '.';
    }

    fn c_at(self: *Engine, index_line: usize, index_char: usize) u8 {
        return self.lines.items[index_line].line[index_char];
    }


    fn has_adjacent_symbol(self: *Engine, index_line: usize, begin_nb: usize, end_nb: usize) bool {
        // on the left of line
        if (begin_nb > 0 and Engine.is_symbol(self.c_at(index_line, begin_nb-1))) {
            std.log.info("SYM on left of line\n", .{});
            return true;
        }

        // left top
        if (index_line > 0 and begin_nb > 0 and Engine.is_symbol(self.c_at(index_line-1, begin_nb-1))) {
            std.log.info("SYM on left top\n", .{});
            return true;
        }

        // left bottom
        if (index_line < self.lines.items.len-1 and begin_nb > 0 and Engine.is_symbol(self.c_at(index_line+1, begin_nb-1))) {
            std.log.info("SYM on left bottom\n", .{});
            return true;
        }

        // on the right of line
        // todo add test
        // https://www.phind.com/search?cache=hmyfiawwqb1qa9ej01y1s2qn
        if (end_nb < self.lines.items[index_line].line.len-1 and Engine.is_symbol(self.c_at(index_line, end_nb+1))) {
            std.log.info("SYM on right of line\n", .{});
            return true;
        }

        // right top
        if (index_line > 0 and end_nb < self.lines.items[index_line].line.len-1 and Engine.is_symbol(self.c_at(index_line-1, end_nb+1))) {
            std.log.info("SYM on right top\n", .{});
            return true;
        }

        // right bottom
        if (index_line < self.lines.items.len-1 and end_nb < self.lines.items[index_line].line.len-1 and Engine.is_symbol(self.c_at(index_line+1, end_nb+1))) {
            std.log.info("SYM on right bottom\n", .{});
            return true;
        }

        var end_nb_loop = end_nb;

        if (end_nb <= self.lines.items[index_line].line.len-1) {
            end_nb_loop = end_nb + 1;
        }

        // loop on the top
        if (index_line > 0) {

            for (self.lines.items[index_line-1].line[begin_nb..end_nb_loop]) |c| {
                if (Engine.is_symbol(c)) {
                    std.log.info("SYM on loop on the top\n", .{});
                    return true;
                }
            }
        }

        // loop on the bottom
        if (index_line < self.lines.items.len-1) {
            for (self.lines.items[index_line+1].line[begin_nb..end_nb_loop]) |c| {
                if (Engine.is_symbol(c)) {
                    std.log.info("SYM on loop on the bottom\n", .{});
                    return true;
                }
            }
        }

        return false;
    }

    pub fn deinit(self: *Engine) void {
        for (self.lines.items) |*line| {
            line.deinit();
        }

        self.lines.deinit();
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var linebuf: [100000]u8 = undefined;
    var engine = try Engine.init(allocator);
    defer engine.deinit();

    while (try in_stream.readUntilDelimiterOrEof(&linebuf, '\n')) |line| {
        var new_line = try Line.init(allocator, line);

        try engine.append(new_line);
    }

    var sum = engine.sum_adjacent_numbers();
    std.log.info("sum = {d}\n", .{sum});
}

test "is_symbol" {
    try std.testing.expectEqual(Engine.is_symbol('a'), true);
    try std.testing.expectEqual(Engine.is_symbol('.'), false);
    try std.testing.expectEqual(Engine.is_symbol('1'), false);
}
