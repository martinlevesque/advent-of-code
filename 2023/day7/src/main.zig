const std = @import("std");

pub const Hand = struct {
    allocator: std.mem.Allocator,
    line: []const u8,
    cards: []const u8,
    bet: u32,

    pub fn init(allocator: std.mem.Allocator, line: []const u8) !Hand {
        var cloned_line = try allocator.alloc(u8, line.len);
        std.mem.copy(u8, cloned_line, line);

        var it = std.mem.split(u8, cloned_line, " ");

        var cards = it.next();

        if (cards == null) {
            return error.MissingCards;
        }

        var bet_s = it.next();

        if (bet_s == null) {
            return error.MissingBet;
        }

        var bet = try std.fmt.parseInt(u32, bet_s.?, 10);

        return Hand{ .line = cloned_line, .cards = cards.?, .bet = bet, .allocator = allocator };
    }

    pub fn deinit(self: *const Hand) void {
        self.allocator.free(self.line);
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

    pub fn base_value(self: *const Hand) !u32 {
        if (try self.is_five_of_a_kind()) {
            return 100;
        } else if (try self.is_four_of_a_kind()) {
            return 90;
        } else if (try self.is_full_house()) {
            return 80;
        } else if (try self.is_three_of_a_kind()) {
            return 70;
        } else if (try self.is_two_pair()) {
            return 60;
        } else if (try self.is_one_pair()) {
            return 50;
        } else if (try self.is_high_card()) {
            return 40;
        } else {
            return error.InvalidHand;
        }
    }
};

// todo
// A, K, Q, J, T, 9, 8, 7, 6, 5, 4, 3, or 2
// need to add in less than

pub fn hand_is_less_than(_: void, h1: Hand, h2: Hand) bool {
    var v_left = h1.base_value() catch { return false; };
    var v_right = h2.base_value() catch { return false; };
    std.log.info("in hand is less..\n", .{});
    std.log.info("v_left = {d}\n", .{v_left});
    std.log.info("v_right = {d}\n", .{v_right});
    std.log.info("h1 = {s}\n", .{h1.cards});
    std.log.info("h2 = {s}\n", .{h2.cards});


    if (v_left == v_right) {
        std.log.info("is eqq\n", .{});

        for (0..h1.cards.len) |i| {
            std.log.info("h1.cards[i] = {any} h2 {any}\n", .{h1.cards[i], h2.cards[i]});
            if (h1.cards[i] < h2.cards[i]) {
                std.log.info("h1.cards[i] < h2.cards[i] for i {d}\n", .{i});
                return true;
            } else if (h1.cards[i] > h2.cards[i]) {
                return false;
            }
        }
    }

    return v_left < v_right;
}



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
        var hand = try Hand.init(allocator, line);

        std.log.info("adding hand = {s}\n", .{hand.line});
        try hands.append(hand);
    }

    for (hands.items) |hand| {
        std.log.info("ORIG hand = {s}\n", .{hand.line});
    }

    var hands_slice = try hands.toOwnedSlice();
    defer allocator.free(hands_slice);

    std.sort.insertion(Hand, hands_slice, {}, hand_is_less_than);
    //quicksort(hands_slice, hand_is_less_than);

    for (hands_slice) |hand| {
        std.log.info("sorted hand = {s}\n", .{hand.line});
        hand.deinit();
    }
}

test "Hand.init" {
    var allocator = std.testing.allocator;
    var hand = try Hand.init(allocator, "12345 100");
    defer hand.deinit();
    try std.testing.expectEqual(hand.bet, 100);
    try std.testing.expect(std.mem.eql(u8, hand.cards, "12345"));
}

test "is_five_of_a_kind" {
    var allocator = std.testing.allocator;
    var hand = try Hand.init(allocator, "AAAAA 100");
    defer hand.deinit();
    try std.testing.expectEqual(try hand.is_five_of_a_kind(), true);

    var hand_2 = try Hand.init(allocator, "2AAAA 100");
    defer hand_2.deinit();
    try std.testing.expectEqual(try hand_2.is_five_of_a_kind(), false);
}

test "is_four_of_a_kind" {
    var allocator = std.testing.allocator;
    var hand = try Hand.init(allocator, "AAAAA 100");
    defer hand.deinit();
    try std.testing.expectEqual(try hand.is_four_of_a_kind(), false);

    var hand_2 = try Hand.init(allocator, "2AAAA 100");
    defer hand_2.deinit();
    try std.testing.expectEqual(try hand_2.is_four_of_a_kind(), true);
}

test "is_full_house" {
    var allocator = std.testing.allocator;
    var hand = try Hand.init(allocator, "AAAAA 100");
    try std.testing.expectEqual(try hand.is_full_house(), false);
    hand.deinit();

    hand = try Hand.init(allocator, "AABBB 100");
    try std.testing.expectEqual(try hand.is_full_house(), true);
    hand.deinit();

    hand = try Hand.init(allocator, "ABABB 100");
    try std.testing.expectEqual(try hand.is_full_house(), true);
    hand.deinit();
}

test "is_three_of_a_kind" {
    var allocator = std.testing.allocator;
    var hand = try Hand.init(allocator, "ABBB8 100");
    try std.testing.expectEqual(try hand.is_three_of_a_kind(), true);
    hand.deinit();

    hand = try Hand.init(allocator, "AABBB 100");
    try std.testing.expectEqual(try hand.is_three_of_a_kind(), false);
    hand.deinit();

    hand = try Hand.init(allocator, "A1100 100");
    try std.testing.expectEqual(try hand.is_three_of_a_kind(), false);
    hand.deinit();
}

test "is_two_pair" {
    var allocator = std.testing.allocator;
    var hand = try Hand.init(allocator, "1BB22 100");
    try std.testing.expectEqual(try hand.is_two_pair(), true);
    hand.deinit();

    hand = try Hand.init(allocator, "AABBB 100");
    try std.testing.expectEqual(try hand.is_two_pair(), false);
    hand.deinit();

    hand = try Hand.init(allocator, "AA123 100");
    try std.testing.expectEqual(try hand.is_two_pair(), false);
    hand.deinit();
}

test "is_one_pair" {
    var allocator = std.testing.allocator;
    var hand = try Hand.init(allocator, "1BB35 100");
    try std.testing.expectEqual(try hand.is_one_pair(), true);
    hand.deinit();

    hand = try Hand.init(allocator, "AABB1 100");
    try std.testing.expectEqual(try hand.is_one_pair(), false);
    hand.deinit();
}

test "is_high_card" {
    var allocator = std.testing.allocator;
    var hand_1 = try Hand.init(allocator, "12345 100");
    defer hand_1.deinit();
    try std.testing.expectEqual(try hand_1.is_high_card(), true);

    var hand_2 = try Hand.init(allocator, "AA234 100");
    defer hand_2.deinit();
    try std.testing.expectEqual(try hand_2.is_high_card(), false);
}

test "count_chars_occurences" {
    var allocator = std.testing.allocator;
    var hand = try Hand.init(allocator, "AAAAA 100");
    defer hand.deinit();
    var counts_1 = try hand.count_chars_occurences();
    defer counts_1.deinit();

    try std.testing.expectEqual(counts_1.count(), 1);
    try std.testing.expectEqual(counts_1.get('A').?, 5);

    var hand_2 = try Hand.init(allocator, "2AAAA 100");
    defer hand_2.deinit();
    var counts_2 = try hand_2.count_chars_occurences();
    defer counts_2.deinit();

    try std.testing.expectEqual(counts_2.count(), 2);
    try std.testing.expectEqual(counts_2.get('A').?, 4);
    try std.testing.expectEqual(counts_2.get('2').?, 1);
}

test "base_value" {
    var allocator = std.testing.allocator;
    var hand = try Hand.init(allocator, "AAAAA 100");
    defer hand.deinit();

    try std.testing.expectEqual(hand.base_value(), 100);
}

// hand_is_less_than(_: void, h1: Hand, h2: Hand) bool
test "hand_is_less_than" {
    var allocator = std.testing.allocator;
    var hand_1 = try Hand.init(allocator, "KK677 100");
    defer hand_1.deinit();

    var hand_2 = try Hand.init(allocator, "KTJJT 100");
    defer hand_2.deinit();

    try std.testing.expectEqual(hand_is_less_than({}, hand_1, hand_2), true);
    try std.testing.expectEqual(hand_is_less_than({}, hand_2, hand_1), false);
}
