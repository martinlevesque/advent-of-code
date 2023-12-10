const std = @import("std");

pub const Mapping = struct {
    // example: Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
    allocator: std.mem.Allocator,
    lines: std.ArrayList([] u8),

    pub fn init(allocator: std.mem.Allocator) Mapping {
        var grouped_lines = std.ArrayList([] u8).init(allocator);

        return Mapping{
            .allocator = allocator,
            .lines = grouped_lines,
        };
    }

    pub fn append_line(self: *Mapping, line: []const u8) !void {
        // clone line
        var line_copy = try self.allocator.alloc(u8, line.len);
        std.mem.copy(u8, line_copy, line);

        try self.lines.append(line_copy);
    }

    pub fn seeds(self: *Mapping) !std.ArrayList(u64) {
        var first_line = self.lines.items[0];

        var it = std.mem.split(u8, first_line, "seeds:");
        var first_item = it.next();

        if (first_item == null) {
            return error.MissingSeeds;
        }

        var seed_numbers = it.next();

        if (seed_numbers == null) {
            return error.MissingSeeds;
        }

        return try Mapping.read_numbers(seed_numbers.?, self.allocator);
    }

    pub fn find_ouput(self: *Mapping, input_number: u64) !u64 {
        for (self.lines.items) |line| {
            // contains :
            if (std.mem.indexOf(u8, line, ":") != null) {
                continue;
            }

            var numbers_setup = try Mapping.read_numbers(line, self.allocator);
            defer numbers_setup.deinit();

            if (numbers_setup.items.len != 3) {
                std.debug.print("ERROR setup items {s}\n", .{line});
                continue;
            }

            var nb_interval = numbers_setup.items[2];
            var destination = numbers_setup.items[0];
            var source = numbers_setup.items[1];
            var orig_source = numbers_setup.items[1];

            if (input_number >= source and input_number <= source + nb_interval) {
                const increment = input_number - orig_source;

                return destination + increment;
            }
        }

        return input_number;
    }

    pub fn read_numbers(line: []const u8, allocator: std.mem.Allocator) !std.ArrayList(u64) {
        var numbers = std.ArrayList(u64).init(allocator);

        var it = std.mem.split(u8, line, " ");

        while (it.next()) |part| {
            var trimmed = std.mem.trim(u8, part, " ");

            if (trimmed.len == 0) {
                continue;
            }

            var number = try std.fmt.parseInt(u64, trimmed, 10);
            try numbers.append(number);
        }

        return numbers;
    }

    pub fn lower_location_number(mappings: std.ArrayList(Mapping)) !u64 {
        var result: ?u64 = null;

        var seed_ids = try mappings.items[0].seeds();
        defer seed_ids.deinit();

        for (seed_ids.items) |seed| {
            var current_input = seed;

            for (mappings.items, 0..) |*mapping, index| {
                if (index == 0) {
                    continue;
                }

                var output_result = try mapping.find_ouput(current_input);

                current_input = output_result;
            }

            std.debug.print("Seed {d}, location is {d}\n", .{seed, current_input});
            if (result == null or current_input < result.?) {
                result = current_input;
            }
        }

        return result.?;
    }

    pub fn deinit(self: *Mapping) void {
        for (self.lines.items) |line| {
            self.allocator.free(line);
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
    var current_mapping = Mapping.init(allocator);

    var mappings = std.ArrayList(Mapping).init(allocator);
    defer mappings.deinit();

    while (try in_stream.readUntilDelimiterOrEof(&linebuf, '\n')) |line| {
        std.log.info("line = {s}\n", .{line});

        if (line.len == 0) {
            try mappings.append(current_mapping);
            current_mapping = Mapping.init(allocator);
        } else {
            try current_mapping.append_line(line);
        }
    }

    if (current_mapping.lines.items.len > 0) {
        try mappings.append(current_mapping);
    }

    var result_part_1 = try Mapping.lower_location_number(mappings);
    std.log.info("Part 1 result: {d}\n", .{result_part_1});

    // free mappings
    for (mappings.items) |*mapping| {
        mapping.deinit();
    }
}

test "seeds" {
    var allocator = std.testing.allocator;

    var mapping = Mapping.init(allocator);
    defer mapping.deinit();

    try mapping.append_line("seeds: 11 2 33 4 5");
    try mapping.append_line("");

    var seeds = try mapping.seeds();
    defer seeds.deinit();

    try std.testing.expectEqual(seeds.items.len, 5);
    try std.testing.expectEqual(seeds.items[0], 11);
    try std.testing.expectEqual(seeds.items[1], 2);
    try std.testing.expectEqual(seeds.items[2], 33);
    try std.testing.expectEqual(seeds.items[3], 4);
    try std.testing.expectEqual(seeds.items[4], 5);
}

test "find_output" {
    var allocator = std.testing.allocator;

    var mapping = Mapping.init(allocator);
    defer mapping.deinit();

    try mapping.append_line("seed-to-soil map:");
    try mapping.append_line("50 98 2");
    try mapping.append_line("52 50 48");

    try std.testing.expectEqual(mapping.find_ouput(98), 50);
    try std.testing.expectEqual(mapping.find_ouput(99), 51);
    try std.testing.expectEqual(mapping.find_ouput(52), 54);
    try std.testing.expectEqual(mapping.find_ouput(2000), 2000);
}