const std = @import("std");

pub const MappingLine = struct {
    destination: u64,
    source: u64,
    nb_interval: u64,
};

pub const Mapping = struct {
    // example: Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
    allocator: std.mem.Allocator,
    lines: std.ArrayList([] u8),
    mapping_lines: std.ArrayList(MappingLine),

    pub fn init(allocator: std.mem.Allocator) Mapping {
        var grouped_lines = std.ArrayList([] u8).init(allocator);
        var mapping_lines = std.ArrayList(MappingLine).init(allocator);

        return Mapping{
            .allocator = allocator,
            .lines = grouped_lines,
            .mapping_lines = mapping_lines,
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

    pub fn seeds_part_2(self: *Mapping) !std.ArrayList(u64) {
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

        var seed_values = try Mapping.read_numbers(seed_numbers.?, self.allocator);
        defer seed_values.deinit();

        if (seed_values.items.len == 0) {
            return error.MissingSeeds;
        }

        var result = std.ArrayList(u64).init(self.allocator);

        for (seed_values.items, 0..) |_, index| {
            if (index % 2 == 1) {
                var nb_interval = seed_values.items[index];
                var previous = seed_values.items[index - 1];

                for (nb_interval, 0..) |_, i| {
                    try result.append(previous + i);
                }
            }
        }

        return result;
    }

    pub fn find_ouput(self: *Mapping, input_number: u64) !u64 {
        for (self.mapping_lines.items) |mapping_line| {
            if (input_number >= mapping_line.source and input_number < mapping_line.source + mapping_line.nb_interval) {
                const increment = input_number - mapping_line.source;

                return mapping_line.destination + increment;
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

        std.debug.print("computing seeds...\n", .{});
        var seed_ids = try mappings.items[0].seeds_part_2();
        std.debug.print("done computing seeds.\n", .{});
        defer seed_ids.deinit();
        const nb_seeds = seed_ids.items.len;

        for (seed_ids.items, 0..) |seed, i| {
            var current_input = seed;

            for (mappings.items, 0..) |*mapping, index| {
                if (index == 0) {
                    continue;
                }

                var output_result = try mapping.find_ouput(current_input);

                current_input = output_result;
            }

            if (i % 1000000 == 1) {
                std.debug.print("Seed {d}, location is {d}, {d}/{d}\n", .{seed, current_input, i, nb_seeds});
            }

            if (result == null or current_input < result.?) {
                result = current_input;
            }
        }

        return result.?;
    }

    pub fn precompute_given_mapping(mapping: *Mapping) !void {
        std.debug.print("precomputing mapping lines\n", .{});

        for (mapping.lines.items) |line| {
            // contains :
            if (std.mem.indexOf(u8, line, ":") != null) {
                continue;
            }

            var numbers_setup = try Mapping.read_numbers(line, mapping.allocator);
            defer numbers_setup.deinit();

            if (numbers_setup.items.len != 3) {
                std.debug.print("ERROR setup items {s}\n", .{line});
                continue;
            }

            var nb_interval = numbers_setup.items[2];
            var destination = numbers_setup.items[0];
            var source = numbers_setup.items[1];

            const mapping_line = MappingLine{
                .destination = destination,
                .source = source,
                .nb_interval = nb_interval,
            };

            try mapping.mapping_lines.append(mapping_line);
        }
    }

    pub fn precompute_mapping_lines(mappings: std.ArrayList(Mapping)) !void {
        std.debug.print("precomputing mapping lines\n", .{});

        for (mappings.items) |*mapping| {
            try Mapping.precompute_given_mapping(mapping);
        }
    }

    pub fn deinit(self: *Mapping) void {
        for (self.lines.items) |line| {
            self.allocator.free(line);
        }

        self.lines.deinit();
        self.mapping_lines.deinit();
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

    try Mapping.precompute_mapping_lines(mappings);
    std.log.info("done precomputing\n", .{});

    var result_part_1 = try Mapping.lower_location_number(mappings);
    std.log.info("Final result: {d}\n", .{result_part_1});

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
    try mapping.append_line("200 0 10");

    try Mapping.precompute_given_mapping(&mapping);

    try std.testing.expectEqual(mapping.find_ouput(98), 50);
    try std.testing.expectEqual(mapping.find_ouput(99), 51);
    try std.testing.expectEqual(mapping.find_ouput(100), 100);
    try std.testing.expectEqual(mapping.find_ouput(52), 54);
    try std.testing.expectEqual(mapping.find_ouput(2000), 2000);
    try std.testing.expectEqual(mapping.find_ouput(0), 200);
    try std.testing.expectEqual(mapping.find_ouput(1), 201);
    try std.testing.expectEqual(mapping.find_ouput(9), 209);
}

test "seeds_part_2" {
    var allocator = std.testing.allocator;

    var mapping = Mapping.init(allocator);
    defer mapping.deinit();

    try mapping.append_line("seeds: 11 2 33 4 5 10");
    try mapping.append_line("");

    var seeds = try mapping.seeds_part_2();
    defer seeds.deinit();

    try std.testing.expectEqual(seeds.items.len, 14);
    try std.testing.expectEqual(seeds.items[0], 11);
    try std.testing.expectEqual(seeds.items[1], 12);
    try std.testing.expectEqual(seeds.items[2], 33);
    try std.testing.expectEqual(seeds.items[3], 34);
    try std.testing.expectEqual(seeds.items[4], 35);
    try std.testing.expectEqual(seeds.items[5], 36);
    try std.testing.expectEqual(seeds.items[6], 5);
    try std.testing.expectEqual(seeds.items[7], 6);
    try std.testing.expectEqual(seeds.items[8], 7);
    try std.testing.expectEqual(seeds.items[9], 8);
    try std.testing.expectEqual(seeds.items[10], 9);
    try std.testing.expectEqual(seeds.items[11], 10);
    try std.testing.expectEqual(seeds.items[12], 13);
    try std.testing.expectEqual(seeds.items[13], 14);
}
