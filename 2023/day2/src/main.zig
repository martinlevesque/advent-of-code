const std = @import("std");

pub const GameSet = struct {
    nb_blue: i32 = 0,
    nb_red: i32 = 0,
    nb_green: i32 = 0,

    pub fn init() GameSet {
        return GameSet{ .nb_blue = 0, .nb_red = 0, .nb_green = 0 };
    }

    pub fn multiplied(self: GameSet) i32 {
        return self.nb_blue * self.nb_red * self.nb_green;
    }
};

pub const Game = struct {
    original_line_setup: []const u8,
    id: i32,
    allocator: std.mem.Allocator,
    sets: []GameSet,

    pub fn init(allocator: std.mem.Allocator, original_line_setup: []const u8) !Game {
        // line example Game 2: 10 blue, 12 red; 8 red; 7 green, 5 red, 7 blue

        // parse left part (Game 2)
        var it_line_parts = std.mem.split(u8, original_line_setup, ":");

        var game_id_part = it_line_parts.next();

        if (game_id_part == null) {
            return error.GameIdMalformed;
        }

        // parse right part
        var sets_part = it_line_parts.next();

        if (sets_part == null) {
            return error.GameSetsMalformed;
        }

        std.log.info("sets_part = {s}\n", .{sets_part.?});
        var sets = try Game.parse_sets_part(allocator, sets_part.?);

        std.log.info("sets:", .{});

        for (sets) |set| {
            std.log.info("  {any}\n", .{set});
        }

        return Game{
            .allocator = allocator,
            .sets = sets,
            .original_line_setup = original_line_setup,
            .id = try Game.game_id_part_to_int(game_id_part.?),
        };
    }

    pub fn deinit(self: *Game) void {
        self.allocator.free(self.sets);
    }

    pub fn game_id_part_to_int(game_id_str: []const u8) !i32 {
        var it = std.mem.split(u8, game_id_str, " ");
        var first_part = it.next();

        if (first_part == null) {
            return error.GameIdNotFound;
        }

        var game_id_part = it.next();

        if (game_id_part == null) {
            return error.GameIdNotFound;
        }

        var game_id = std.fmt.parseInt(i32, game_id_part.?, 10) catch |err| {
            return err;
        };

        return game_id;
    }

    pub fn parse_sets_part(allocator: std.mem.Allocator, sets_part: []const u8) ![]GameSet {
        var it_semicolon = std.mem.split(u8, sets_part, ";");
        var nb_semicolons = std.mem.count(u8, sets_part, ";") + 1;

        var sets = try allocator.alloc(GameSet, nb_semicolons);
        var cur_set_index: usize = 0;

        while (it_semicolon.next()) |set_part| {
            // set_part example "2 red, 9 green, 11 blue"
            var it_comma_delimited = std.mem.split(u8, set_part, ",");
            sets[cur_set_index] = GameSet.init();

            while (it_comma_delimited.next()) |color_count| {
                var trimmed = std.mem.trim(u8, color_count, " ");

                var it_color_parts = std.mem.split(u8, trimmed, " ");
                var nb_colors_str = it_color_parts.next();

                if (nb_colors_str == null) {
                    return error.GameSetMalformedColor;
                }

                var nb_of_color = std.fmt.parseInt(i32, nb_colors_str.?, 10) catch |err| {
                    return err;
                };

                var color = it_color_parts.next();

                if (color == null) {
                    return error.GameSetMalformedColor;
                }

                if (std.mem.eql(u8, color.?, "blue")) {
                    sets[cur_set_index].nb_blue = nb_of_color;
                } else if (std.mem.eql(u8, color.?, "red")) {
                    sets[cur_set_index].nb_red = nb_of_color;
                } else if (std.mem.eql(u8, color.?, "green")) {
                    sets[cur_set_index].nb_green = nb_of_color;
                } else {
                    return error.GameInvalidColor;
                }
            }

            cur_set_index += 1;
        }

        return sets;
    }

    // part 1:
    pub fn is_possible(self: *Game, nb_red: i32, nb_green: i32, nb_blue: i32) bool {
        for (self.sets) |set| {
            if (set.nb_red > nb_red or set.nb_green > nb_green or set.nb_blue > nb_blue) {
                return false;
            }
        }

        return true;
    }

    // part 2:
    pub fn minimum_set_cubes(self: *Game) GameSet {
        var set = GameSet.init();

        for (self.sets) |s| {
            if (s.nb_blue > set.nb_blue) {
                set.nb_blue = s.nb_blue;
            }

            if (s.nb_red > set.nb_red) {
                set.nb_red = s.nb_red;
            }

            if (s.nb_green > set.nb_green) {
                set.nb_green = s.nb_green;
            }
        }

        return set;
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

    var buf: [100000]u8 = undefined;
    var sum_possible_games: i32 = 0;
    var sum_min_sets: i32 = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        std.log.info("line = {s}\n", .{line});

        var game = try Game.init(allocator, line);
        defer game.deinit();

        if (game.is_possible(12, 13, 14)) {
            sum_possible_games += game.id;
        }

        std.log.info("game -> {any}\n", .{game});

        var min_set = game.minimum_set_cubes();
        var set_multiplied = min_set.multiplied();

        sum_min_sets += set_multiplied;

        std.log.info("min set -> {any}\n", .{min_set});
        std.log.info("set multiplied -> {d}\n", .{set_multiplied});
    }

    std.log.info("sum possible games {d}\n", .{sum_possible_games});
    std.log.info("sum_min_sets {d}\n", .{sum_min_sets});
}

test "game_id_part_to_int happy path" {
    var game_id_part = "Game 1234";
    var game_id = try Game.game_id_part_to_int(game_id_part);
    try std.testing.expectEqual(game_id, 1234);
}

test "game_id_part_to_int invalid" {
    var game_id_part = "Game1234";
    var result = Game.game_id_part_to_int(game_id_part);

    try std.testing.expectError(error.GameIdNotFound, result);
}

test "parse_sets_part" {
    var allocator = std.testing.allocator;
    var sets = try Game.parse_sets_part(
        allocator,
        "10 blue, 12 red; 8 red; 7 green, 5 red, 7 blue"
    );
    defer allocator.free(sets);

    try std.testing.expectEqual(sets.len, 3);
    try std.testing.expectEqual(sets[0].nb_blue, 10);
    try std.testing.expectEqual(sets[0].nb_red, 12);
    try std.testing.expectEqual(sets[0].nb_green, 0);
    try std.testing.expectEqual(sets[1].nb_blue, 0);
    try std.testing.expectEqual(sets[1].nb_red, 8);
    try std.testing.expectEqual(sets[1].nb_green, 0);
    try std.testing.expectEqual(sets[2].nb_blue, 7);
    try std.testing.expectEqual(sets[2].nb_red, 5);
    try std.testing.expectEqual(sets[2].nb_green, 7);
}
