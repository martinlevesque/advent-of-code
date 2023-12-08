const std = @import("std");

pub const Position = struct {
    line_index: usize,
    column_index: usize,
};

pub const NumberPositionResult = struct {
    number: i32,
    column_begin: usize,
    column_end: usize,
};

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

    // part 1
    pub fn sum_adjacent_numbers(self: *Engine) i32 {
        var sum: i32 = 0;

        for (self.lines.items, 0..) |*line, index_line| {
            var begin_n: ?usize = null;
            var end_n: ?usize = null;

            for (line.line, 0..) |c, index_char| {
                if (Engine.is_number(c) and begin_n == null) {
                    begin_n = index_char;
                } else {
                    if ((Engine.is_number(c) == false or index_char == line.line.len - 1) and begin_n != null) {
                        if (Engine.is_number(c)) {
                            end_n = index_char;
                        } else {
                            end_n = index_char - 1;
                        }

                        var adj = self.adjacent_char(is_symbol, index_line, begin_n.?, end_n.?, null);

                        if (adj != null) {
                            var number_s = line.line[begin_n.? .. end_n.? + 1];
                            var number = std.fmt.parseInt(i32, number_s, 10) catch {
                                return 0;
                            };
                            sum += number;
                        }

                        begin_n = null;
                        end_n = null;
                    }
                }
            }
        }

        return sum;
    }

    // part 2
    pub fn sum_gear_ratios(self: *Engine) i32 {
        var sum: i32 = 0;

        for (self.lines.items, 0..) |*line, index_line| {
            std.log.info("current line .. {s} {d}\n", .{ line.line, index_line });

            for (line.line, 0..) |c, index_char| {
                if (c == '*') {
                    std.log.info("star found!", .{});
                    var first_number_position = self.adjacent_char(predicate_is_number, index_line, index_char, index_char, null);
                    std.log.info("adj char first_number_position..! {any}\n", .{first_number_position});

                    if (first_number_position == null) {
                        continue;
                    } else {
                        var second_number_position = self.adjacent_char(predicate_is_number, index_line, index_char, index_char, first_number_position);

                        std.log.info("adj char second number..! {any}\n", .{second_number_position});

                        if (second_number_position != null) {
                            var first_number = Engine.find_number_from_position(self.lines.items[first_number_position.?.line_index].line, first_number_position.?.column_index);
                            var second_number = Engine.find_number_from_position(self.lines.items[second_number_position.?.line_index].line, second_number_position.?.column_index);

                            std.log.info("first number {d}\n", .{first_number.number});
                            std.log.info("second number {d}\n", .{second_number.number});

                            sum += first_number.number * second_number.number;
                        }
                    }
                }
            }
        }

        return sum;
    }

    fn find_number_from_position(line: []const u8, index: usize) NumberPositionResult {
        std.debug.print("find number from pos line {s} index {d} {c}\n", .{ line, index, line[index] });

        if (Engine.is_number(line[index]) == false) {
            return NumberPositionResult{ .number = -1, .column_begin = 0, .column_end = 0 };
        }

        var current_index = index;

        while (current_index > 0 and Engine.is_number(line[current_index])) {
            current_index -= 1;
        }

        var begin_at = current_index + 1;

        if (Engine.is_number(line[current_index])) {
            begin_at = current_index;
        }

        // find right part
        current_index = index;

        while (current_index < line.len - 1 and Engine.is_number(line[current_index])) {
            current_index += 1;
        }

        var end_at = current_index - 1;

        if (Engine.is_number(line[current_index])) {
            std.log.info("going here.", .{});
            end_at = current_index;
        }

        std.log.info("line = {s}\n", .{line});
        std.log.info("begin_at = {d}\n", .{begin_at});
        std.log.info("end_at = {d}\n", .{end_at});

        var number_s = line[begin_at .. end_at + 1];
        var number = std.fmt.parseInt(i32, number_s, 10) catch {
            return NumberPositionResult{ .number = -1, .column_begin = 0, .column_end = 0 };
        };

        return NumberPositionResult{ .number = number, .column_begin = begin_at, .column_end = end_at };
    }

    fn is_symbol(line: []const u8, current_position: Position, skip_at: ?Position) bool {
        const c = line[current_position.column_index];

        if (skip_at != null) {
            if (current_position.line_index == skip_at.?.line_index and current_position.column_index == skip_at.?.column_index) {
                return false;
            }
        }

        return Engine.is_number(c) == false and c != '.';
    }

    fn predicate_is_number(line: []const u8, current_position: Position, skip_at: ?Position) bool {
        const c = line[current_position.column_index];

        if (Engine.is_number(c) == false) {
            return false;
        }

        if (skip_at != null) {
            var number_1 = Engine.find_number_from_position(line, current_position.column_index);
            var number_2 = Engine.find_number_from_position(line, skip_at.?.column_index);

            std.log.info("number_1 {any}\n", .{number_1});
            std.log.info("number_2 {any}\n", .{number_2});

            if (current_position.line_index == skip_at.?.line_index and
                number_1.column_begin == number_2.column_begin and
                number_1.column_end == number_2.column_end)
            {
                return false;
            }
        }

        return true;
    }

    fn c_at(self: *Engine, position: Position) u8 {
        return self.lines.items[position.line_index].line[position.column_index];
    }

    fn adjacent_char(
        self: *Engine,
        comptime predicate: fn (line: []const u8, cur_pos: Position, skip_at: ?Position) bool,
        index_line: usize,
        begin_nb: usize,
        end_nb: usize,
        skip_at: ?Position,
    ) ?Position {
        // on the left of line
        var position: Position = undefined;
        const cur_line = self.lines.items[index_line].line;

        if (begin_nb > 0) {
            position = Position{ .line_index = index_line, .column_index = begin_nb - 1 };

            if (predicate(cur_line, position, skip_at)) {
                std.debug.print("SYM on left of line\n", .{});
                return position;
            }
        }

        // left top
        if (index_line > 0 and begin_nb > 0) {
            position = Position{ .line_index = index_line - 1, .column_index = begin_nb - 1 };

            if (predicate(self.lines.items[index_line - 1].line, position, skip_at)) {
                std.debug.print("SYM on left top\n", .{});
                return position;
            }
        }

        // left bottom

        if (index_line < self.lines.items.len - 1 and begin_nb > 0) {
            position = Position{ .line_index = index_line + 1, .column_index = begin_nb - 1 };

            if (predicate(self.lines.items[index_line + 1].line, position, skip_at)) {
                std.log.info("SYM on left bottom\n", .{});
                return position;
            }
        }

        // on the right of line
        if (end_nb < self.lines.items[index_line].line.len - 1) {
            position = Position{ .line_index = index_line, .column_index = end_nb + 1 };

            if (predicate(self.lines.items[index_line].line, position, skip_at)) {
                std.log.info("SYM on right of line\n", .{});
                return position;
            }
        }

        // right top
        if (index_line > 0 and end_nb < self.lines.items[index_line].line.len - 1) {
            position = Position{ .line_index = index_line - 1, .column_index = end_nb + 1 };

            if (predicate(self.lines.items[index_line - 1].line, position, skip_at)) {
                std.log.info("SYM on right top\n", .{});
                return Position{ .line_index = index_line - 1, .column_index = end_nb + 1 };
            }
        }

        // right bottom
        if (index_line < self.lines.items.len - 1 and end_nb < self.lines.items[index_line].line.len - 1) {
            position = Position{ .line_index = index_line + 1, .column_index = end_nb + 1 };

            if (predicate(self.lines.items[index_line + 1].line, position, skip_at)) {
                std.log.info("SYM on right bottom\n", .{});
                return Position{ .line_index = index_line + 1, .column_index = end_nb + 1 };
            }
        }

        var end_nb_loop = end_nb;

        if (end_nb <= self.lines.items[index_line].line.len - 1) {
            end_nb_loop = end_nb + 1;
        }

        // loop on the top
        if (index_line > 0) {
            var index = begin_nb;
            for (self.lines.items[index_line - 1].line[begin_nb..end_nb_loop]) |_| {
                position = Position{ .line_index = index_line - 1, .column_index = index };
                if (predicate(self.lines.items[index_line - 1].line, position, skip_at)) {
                    std.log.info("SYM on loop on the top\n", .{});
                    return Position{ .line_index = index_line - 1, .column_index = index };
                }

                index += 1;
            }
        }

        // loop on the bottom
        if (index_line < self.lines.items.len - 1) {
            var index = begin_nb;
            for (self.lines.items[index_line + 1].line[begin_nb..end_nb_loop]) |_| {
                position = Position{ .line_index = index_line + 1, .column_index = index };
                if (predicate(self.lines.items[index_line + 1].line, position, skip_at)) {
                    std.log.info("SYM on loop on the bottom\n", .{});
                    return Position{ .line_index = index_line + 1, .column_index = index };
                }

                index += 1;
            }
        }

        return null;
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
    std.log.info("Part 1 sum = {d}\n", .{sum});

    var sum_part_2 = engine.sum_gear_ratios();
    std.log.info("Part 2 sum = {d}\n", .{sum_part_2});
}

test "is_symbol" {
    var pos = Position{ .line_index = 0, .column_index = 0 };

    try std.testing.expectEqual(Engine.is_symbol("a", pos, null), true);
    try std.testing.expectEqual(Engine.is_symbol(".", pos, null), false);
    try std.testing.expectEqual(Engine.is_symbol("1", pos, null), false);
}

test "find_number_from_position" {
    try std.testing.expectEqual(Engine.find_number_from_position("..23..", 3).number, 23);
    try std.testing.expectEqual(Engine.find_number_from_position("..23..", 3).column_begin, 2);
    try std.testing.expectEqual(Engine.find_number_from_position("..23..", 3).column_end, 3);

    try std.testing.expectEqual(Engine.find_number_from_position("..23..", 0).number, -1);
    try std.testing.expectEqual(Engine.find_number_from_position("23..", 1).number, 23);
    try std.testing.expectEqual(Engine.find_number_from_position("23..", 0).number, 23);
}

test "part 1 - minimal sample" {
    var allocator = std.testing.allocator;

    var engine = try Engine.init(allocator);
    defer engine.deinit();

    try engine.append(try Line.init(allocator, "467..114.."));
    try engine.append(try Line.init(allocator, "...*......"));

    try std.testing.expectEqual(engine.sum_adjacent_numbers(), 467);
}

test "part 1 - sample" {
    var allocator = std.testing.allocator;

    var engine = try Engine.init(allocator);
    defer engine.deinit();

    try engine.append(try Line.init(allocator, "467..114.."));
    try engine.append(try Line.init(allocator, "...*......"));
    try engine.append(try Line.init(allocator, "..35..633."));
    try engine.append(try Line.init(allocator, "......#..."));
    try engine.append(try Line.init(allocator, "617*......"));
    try engine.append(try Line.init(allocator, ".....+.58."));
    try engine.append(try Line.init(allocator, "..592....."));
    try engine.append(try Line.init(allocator, "......755."));
    try engine.append(try Line.init(allocator, "...$.*...."));
    try engine.append(try Line.init(allocator, ".664.598.."));

    try std.testing.expectEqual(engine.sum_adjacent_numbers(), 4361);
}

test "part 1 - number border left" {
    var allocator = std.testing.allocator;

    var engine = try Engine.init(allocator);
    defer engine.deinit();

    try engine.append(try Line.init(allocator, "22*......"));

    try std.testing.expectEqual(engine.sum_adjacent_numbers(), 22);
}

test "part 1 - number border left, symbol left" {
    var allocator = std.testing.allocator;

    var engine = try Engine.init(allocator);
    defer engine.deinit();

    try engine.append(try Line.init(allocator, "*22......"));

    try std.testing.expectEqual(engine.sum_adjacent_numbers(), 22);
}

test "part 1 - left top" {
    var allocator = std.testing.allocator;

    var engine = try Engine.init(allocator);
    defer engine.deinit();

    try engine.append(try Line.init(allocator, "*........"));
    try engine.append(try Line.init(allocator, ".22......"));

    try std.testing.expectEqual(engine.sum_adjacent_numbers(), 22);
}

test "part 1 - left bottom" {
    var allocator = std.testing.allocator;

    var engine = try Engine.init(allocator);
    defer engine.deinit();

    try engine.append(try Line.init(allocator, "........."));
    try engine.append(try Line.init(allocator, ".22......"));
    try engine.append(try Line.init(allocator, "*........"));

    try std.testing.expectEqual(engine.sum_adjacent_numbers(), 22);
}

test "part 1 - right line" {
    var allocator = std.testing.allocator;

    var engine = try Engine.init(allocator);
    defer engine.deinit();

    try engine.append(try Line.init(allocator, "........."));
    try engine.append(try Line.init(allocator, "......23*"));
    try engine.append(try Line.init(allocator, "........."));

    try std.testing.expectEqual(engine.sum_adjacent_numbers(), 23);
}

test "part 1 - right line 2" {
    var allocator = std.testing.allocator;

    var engine = try Engine.init(allocator);
    defer engine.deinit();

    try engine.append(try Line.init(allocator, "........."));
    try engine.append(try Line.init(allocator, "......*23"));
    try engine.append(try Line.init(allocator, "........."));

    try std.testing.expectEqual(engine.sum_adjacent_numbers(), 23);
}

test "part 1 - right top" {
    var allocator = std.testing.allocator;

    var engine = try Engine.init(allocator);
    defer engine.deinit();

    try engine.append(try Line.init(allocator, "........*"));
    try engine.append(try Line.init(allocator, "......23."));
    try engine.append(try Line.init(allocator, "........."));

    try std.testing.expectEqual(engine.sum_adjacent_numbers(), 23);
}

test "part 1 - right top 2" {
    var allocator = std.testing.allocator;

    var engine = try Engine.init(allocator);
    defer engine.deinit();

    try engine.append(try Line.init(allocator, "........*"));
    try engine.append(try Line.init(allocator, ".......23"));
    try engine.append(try Line.init(allocator, "........."));

    try std.testing.expectEqual(engine.sum_adjacent_numbers(), 23);
}

test "part 1 - right bottom" {
    var allocator = std.testing.allocator;

    var engine = try Engine.init(allocator);
    defer engine.deinit();

    try engine.append(try Line.init(allocator, "........."));
    try engine.append(try Line.init(allocator, "......23."));
    try engine.append(try Line.init(allocator, "........*"));

    try std.testing.expectEqual(engine.sum_adjacent_numbers(), 23);
}

test "part 1 - right bottom 2" {
    var allocator = std.testing.allocator;

    var engine = try Engine.init(allocator);
    defer engine.deinit();

    try engine.append(try Line.init(allocator, "........."));
    try engine.append(try Line.init(allocator, ".......23"));
    try engine.append(try Line.init(allocator, "........*"));

    try std.testing.expectEqual(engine.sum_adjacent_numbers(), 23);
}

test "part 2 - sample" {
    var allocator = std.testing.allocator;

    var engine = try Engine.init(allocator);
    defer engine.deinit();

    try engine.append(try Line.init(allocator, "467..114.."));
    try engine.append(try Line.init(allocator, "...*......"));
    try engine.append(try Line.init(allocator, "..35..633."));
    try engine.append(try Line.init(allocator, "......#..."));
    try engine.append(try Line.init(allocator, "617*......"));
    try engine.append(try Line.init(allocator, ".....+.58."));
    try engine.append(try Line.init(allocator, "..592....."));
    try engine.append(try Line.init(allocator, "......755."));
    try engine.append(try Line.init(allocator, "...$.*...."));
    try engine.append(try Line.init(allocator, ".664.598.."));

    try std.testing.expectEqual(engine.sum_gear_ratios(), 467835);
}

test "part 2 - same line left" {
    var allocator = std.testing.allocator;

    var engine = try Engine.init(allocator);
    defer engine.deinit();

    try engine.append(try Line.init(allocator, "467*114.."));
    try engine.append(try Line.init(allocator, "........."));

    try std.testing.expectEqual(engine.sum_gear_ratios(), 53238);
}

test "part 2 - same line right" {
    var allocator = std.testing.allocator;

    var engine = try Engine.init(allocator);
    defer engine.deinit();

    try engine.append(try Line.init(allocator, "..467*114"));
    try engine.append(try Line.init(allocator, "..*......"));
    try engine.append(try Line.init(allocator, "..1....22"));
    try engine.append(try Line.init(allocator, "...*..*.."));
    try engine.append(try Line.init(allocator, "....3..2."));

    try std.testing.expectEqual(engine.sum_gear_ratios(), 53752);
}

// predicate_is_number(line: []const u8, current_position: Position, skip_at: ?Position)
test "predicate_is_number" {
    try std.testing.expectEqual(
        Engine.predicate_is_number("123", Position{ .line_index = 0, .column_index = 0 }, null),
        true,
    );

    try std.testing.expectEqual(
        Engine.predicate_is_number("..123..", Position{ .line_index = 0, .column_index = 1 }, null),
        false,
    );

    var skip_at_pos = Position{ .line_index = 0, .column_index = 4 };
    try std.testing.expectEqual(
        Engine.predicate_is_number("..123..", Position{ .line_index = 0, .column_index = 2 }, skip_at_pos),
        false,
    );

    skip_at_pos = Position{ .line_index = 0, .column_index = 6 };
    try std.testing.expectEqual(
        Engine.predicate_is_number("..123.6", Position{ .line_index = 0, .column_index = 2 }, skip_at_pos),
        true,
    );

    skip_at_pos = Position{ .line_index = 0, .column_index = 6 };
    try std.testing.expectEqual(
        Engine.predicate_is_number("..123.6", Position{ .line_index = 0, .column_index = 0 }, skip_at_pos),
        false,
    );

    skip_at_pos = Position{ .line_index = 1, .column_index = 6 };
    try std.testing.expectEqual(
        Engine.predicate_is_number("..123.6", Position{ .line_index = 0, .column_index = 2 }, skip_at_pos),
        true,
    );
}
