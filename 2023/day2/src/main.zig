const std = @import("std");

pub const GameSet = struct {
    nb_blue: i32,
    nb_red: i32,
    nb_green: i32,
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
        var nb_semicolons = std.mem.count(u8, sets_part, ";");

        var sets = try allocator.alloc(GameSet, nb_semicolons);
        std.log.info("sets {any}", .{sets});

        while (it_semicolon.next()) |set_part| {
            // set_part example "2 red, 9 green, 11 blue"
            std.log.info("set part {s}\n", .{set_part});
            var it_comma_delimited = std.mem.split(u8, set_part, ",");

            while (it_comma_delimited.next()) |color_count| {
                std.log.info("color_count {s}\n", .{color_count});
                var trimmed = std.mem.trim(u8, color_count, " ");
                std.log.info("trimmed--{s}--\n", .{trimmed});

                var it_color_parts = std.mem.split(u8, trimmed, " ");
                var nb_colors_str = it_color_parts.next();

                if (nb_colors_str == null) {
                    return error.GameSetMalformedColor;
                }


                var nb_of_color = std.fmt.parseInt(i32, nb_colors_str.?, 10) catch |err| {
                    return err;
                };

                std.log.info("nb_of_color {d}\n", .{nb_of_color});

                var color = it_color_parts.next();

                if (color == null) {
                    return error.GameSetMalformedColor;
                }
                std.log.info("color {s}\n", .{color.?});


            }

        }

        return sets;
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
    var sum_calibrations: i32 = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        std.log.info("line = {s}\n", .{line});

        var game = try Game.init(allocator, line);
        defer game.deinit();

        
        std.log.info("game -> {any}\n", .{game});
    }

    std.debug.print("sum_calibrations = {d}", .{sum_calibrations});
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
