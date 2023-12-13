const std = @import("std");

pub const Hand = struct {
    allocator: std.mem.Allocator,
    line: []const u8,
    cards: []const u8,
    bet: u32,

    pub fn init(allocator: std.mem.Allocator, line: []const u8) !Hand {
        var it = std.mem.split(u8, line, " ");

        var cards = it.next();

        if (cards == null) {
            return error.MissingCards;
        }

        var bet_s = it.next();

        if (bet_s == null) {
            return error.MissingBet;
        }

        var bet = try std.fmt.parseInt(u32, bet_s.?, 10);

        return Hand{ .line = line, .cards = cards.?, .bet = bet, .allocator = allocator };
    }

    pub fn count_chars_occurences(self: *const Hand) !std.AutoHashMap(u8, u32) {
        var counts: std.AutoHashMap(u8, u32) = std.AutoHashMap(u8, u32).init(self.allocator);

        for (self.cards) |c| {
            var count = counts.get(c);

            if (count == null) {
                try counts.put(c, 1);
            } else {
                try counts.put(c, count.? + 1);
            }
        }

        return counts;
    }

    fn has_n_chars(self: *const Hand, n: u32) !bool {
        var occurences = try self.count_chars_occurences();
        defer occurences.deinit();

        var it = occurences.iterator();

        while (it.next()) |entry| {
            if (entry.value_ptr.* == n) {
                return true;
            }
        }

        return false;
    }

    pub fn is_four_of_a_kind(self: *const Hand) !bool {
        return self.has_n_chars(4);
    }

    pub fn is_five_of_a_kind(self: *const Hand) !bool {
        return self.has_n_chars(5);
    }

    pub fn is_full_house(self: *const Hand) !bool {
        return try self.has_n_chars(2) and try self.has_n_chars(3);
    }

    pub fn is_three_of_a_kind(self: *const Hand) !bool {
        return try self.has_n_chars(3) and try self.has_n_chars(2) == false;
    }

    pub fn is_two_pair(self: *const Hand) !bool {
        var occurences = try self.count_chars_occurences();
        defer occurences.deinit();

        return try self.has_n_chars(2) and occurences.count() == 3;
    }

    pub fn is_one_pair(self: *const Hand) !bool {
        var occurences = try self.count_chars_occurences();
        defer occurences.deinit();

        return try self.has_n_chars(2) and occurences.count() == 4;
    }

    pub fn is_high_card(self: *const Hand) !bool {
        var occurences = try self.count_chars_occurences();
        defer occurences.deinit();

        return occurences.count() == 5;
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

    var hands = std.ArrayList(Hand).init(allocator);
    defer hands.deinit();

    // todo insertion sort

    while (try in_stream.readUntilDelimiterOrEof(&linebuf, '\n')) |line| {
        std.log.info("line = {s}\n", .{line});
        var hand = Hand.init(allocator, line);

        try hands.append(hand);
    }
}

test "Hand.init" {
    var allocator = std.testing.allocator;
    var hand = try Hand.init(allocator, "12345 100");
    try std.testing.expectEqual(hand.bet, 100);
    try std.testing.expect(std.mem.eql(u8, hand.cards, "12345"));
}

test "is_five_of_a_kind" {
    var allocator = std.testing.allocator;
    var hand = try Hand.init(allocator, "AAAAA 100");
    try std.testing.expectEqual(try hand.is_five_of_a_kind(), true);

    hand = try Hand.init(allocator, "2AAAA 100");
    try std.testing.expectEqual(try hand.is_five_of_a_kind(), false);
}

test "is_four_of_a_kind" {
    var allocator = std.testing.allocator;
    var hand = try Hand.init(allocator, "AAAAA 100");
    try std.testing.expectEqual(try hand.is_four_of_a_kind(), false);

    hand = try Hand.init(allocator, "2AAAA 100");
    try std.testing.expectEqual(try hand.is_four_of_a_kind(), true);
}

test "is_full_house" {
    var allocator = std.testing.allocator;
    var hand = try Hand.init(allocator, "AAAAA 100");
    try std.testing.expectEqual(try hand.is_full_house(), false);

    hand = try Hand.init(allocator, "AABBB 100");
    try std.testing.expectEqual(try hand.is_full_house(), true);

    hand = try Hand.init(allocator, "ABABB 100");
    try std.testing.expectEqual(try hand.is_full_house(), true);
}

test "is_three_of_a_kind" {
    var allocator = std.testing.allocator;
    var hand = try Hand.init(allocator, "ABBB8 100");
    try std.testing.expectEqual(try hand.is_three_of_a_kind(), true);

    hand = try Hand.init(allocator, "AABBB 100");
    try std.testing.expectEqual(try hand.is_three_of_a_kind(), false);

    hand = try Hand.init(allocator, "A1100 100");
    try std.testing.expectEqual(try hand.is_three_of_a_kind(), false);
}

test "is_two_pair" {
    var allocator = std.testing.allocator;
    var hand = try Hand.init(allocator, "1BB22 100");
    try std.testing.expectEqual(try hand.is_two_pair(), true);

    hand = try Hand.init(allocator, "AABBB 100");
    try std.testing.expectEqual(try hand.is_two_pair(), false);

    hand = try Hand.init(allocator, "AA123 100");
    try std.testing.expectEqual(try hand.is_two_pair(), false);
}

test "is_one_pair" {
    var allocator = std.testing.allocator;
    var hand = try Hand.init(allocator, "1BB35 100");
    try std.testing.expectEqual(try hand.is_one_pair(), true);

    hand = try Hand.init(allocator, "AABB1 100");
    try std.testing.expectEqual(try hand.is_one_pair(), false);
}

test "is_high_card" {
    var allocator = std.testing.allocator;
    var hand = try Hand.init(allocator, "12345 100");
    try std.testing.expectEqual(try hand.is_high_card(), true);

    hand = try Hand.init(allocator, "AA234 100");
    try std.testing.expectEqual(try hand.is_high_card(), false);
}

test "count_chars_occurences" {
    var allocator = std.testing.allocator;
    var hand = try Hand.init(allocator, "AAAAA 100");
    var counts_1 = try hand.count_chars_occurences();
    defer counts_1.deinit();

    try std.testing.expectEqual(counts_1.count(), 1);
    try std.testing.expectEqual(counts_1.get('A').?, 5);

    hand = try Hand.init(allocator, "2AAAA 100");
    var counts_2 = try hand.count_chars_occurences();
    defer counts_2.deinit();

    try std.testing.expectEqual(counts_2.count(), 2);
    try std.testing.expectEqual(counts_2.get('A').?, 4);
    try std.testing.expectEqual(counts_2.get('2').?, 1);
}
