const std = @import("std");

fn str_exists(list_strs: * const std.ArrayList([]const u8), str: []const u8) bool {
    for (list_strs.items) |hand| {
        if (std.mem.eql(u8, hand, str)) {
            return true;
        }
    }

    return false;
}

pub const CardFound = struct {
    card: u8,
    count: u32,
};

pub const Hand = struct {
    allocator: std.mem.Allocator,
    line: []const u8,
    cards: []const u8,
    bet: u32,
    top_hands: std.ArrayList([]const u8),

    pub fn init(allocator: std.mem.Allocator, line: []const u8) !Hand {
        var cloned_line = try allocator.alloc(u8, line.len);
        std.mem.copy(u8, cloned_line, line);

        var it = std.mem.split(u8, cloned_line, " ");

        var cards = it.next();

        if (cards == null) {
            return error.MissingCards;
        }

        var bet_s = it.next();
        var bet: u32 = 0;

        if (bet_s != null) {
            bet = try std.fmt.parseInt(u32, bet_s.?, 10);
        }

        return Hand{
            .line = cloned_line,
            .cards = cards.?,
            .bet = bet,
            .allocator = allocator,
            .top_hands = std.ArrayList([]const u8).init(allocator),
        };
    }

    pub fn deinit(self: *const Hand) void {
        self.allocator.free(self.line);

        for (self.top_hands.items) |hand| {
            self.allocator.free(hand);
        }
        self.top_hands.deinit();
    }

    pub fn reinit_top_hands(self: *Hand) void {
        for (self.top_hands.items) |hand| {
            self.allocator.free(hand);
        }
        self.top_hands.deinit();

        self.top_hands = std.ArrayList([]const u8).init(self.allocator);
    }


    pub fn append_top_hand(self: *Hand, possible_hand: []const u8) !void {
        // check first if it already exists
        for (self.top_hands.items) |hand| {
            if (std.mem.eql(u8, hand, possible_hand)) {
                return;
            }
        }

        var cloned_possible_hand = try self.allocator.alloc(u8, possible_hand.len);
        std.mem.copy(u8, cloned_possible_hand, possible_hand);

        try self.top_hands.append(cloned_possible_hand);
    }

    pub fn card_value(allocator: std.mem.Allocator, card: u8) !u32 {
        const possible_cards = "J23456789TQKA";

        var card_s = try allocator.alloc(u8, 1);
        defer allocator.free(card_s);
        card_s[0] = card;

        var index_card: ?usize = std.mem.indexOf(u8, possible_cards, card_s);

        if (index_card == null) {
            return 0;
        }

        return @as(u32, @intCast(index_card.?));
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

    pub fn at_least_n_chars(self: *const Hand, n: u32) !?CardFound {
        var occurences = try self.count_chars_occurences();
        defer occurences.deinit();

        var it = occurences.iterator();

        while (it.next()) |entry| {
            if (entry.value_ptr.* >= n) {
                return CardFound{
                    .card = entry.key_ptr.*,
                    .count = entry.value_ptr.*,
                };
            }
        }

        return null;
    }

    pub fn is_four_of_a_kind(self: *const Hand) !bool {
        return try self.at_least_n_chars(4) != null;
    }

    pub fn is_five_of_a_kind(self: *const Hand) !bool {
        return try self.at_least_n_chars(5) != null;
    }

    pub fn is_full_house(self: *const Hand) !bool {
        return try self.has_n_chars(2) and try self.has_n_chars(3);
    }

    pub fn is_three_of_a_kind(self: *const Hand) !bool {
        return try self.at_least_n_chars(3) != null;
    }

    pub fn is_two_pair(self: *const Hand) !bool {
        var occurences = try self.count_chars_occurences();
        defer occurences.deinit();

        return try self.has_n_chars(2) and occurences.count() == 3;
    }

    pub fn is_one_pair(self: *const Hand) !bool {
        return try self.at_least_n_chars(2) != null;
    }

    pub fn is_high_card(_: *const Hand) !bool {
        return true;
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

    pub fn base_value_s(allocator: std.mem.Allocator, hand_s: []const u8) !u32 {
        var hand = try Hand.init(allocator, hand_s);
        defer hand.deinit();

        return try hand.base_value();
    }


    pub fn find_possible_hands(allocator: std.mem.Allocator, current_hand: []const u8, history: *std.ArrayList([]const u8), result: *std.ArrayList([]const u8)) !void {
        if (std.mem.indexOf(u8, current_hand, "JJJJJ") != null) {
            var cards_to_add = try allocator.alloc(u8, 5);
            std.mem.copy(u8, cards_to_add, "22222");

            try result.append(cards_to_add);
            return;
        }


        //std.log.info("find possible hand.. current hand = {s}, result len = {d}\n", .{current_hand, result.items.len});
        for (current_hand, 0..) |card, card_index| {
            if (card == 'J') {
                const possible_cards = "23456789TQKA";

                for (possible_cards) |possible_card| {
                    var cloned_cards = try allocator.alloc(u8, current_hand.len);
                    defer allocator.free(cloned_cards);
                    std.mem.copy(u8, cloned_cards, current_hand);
                    cloned_cards[card_index] = possible_card;

                    if (std.mem.indexOf(u8, cloned_cards, "J") == null) {
                        // skip if exists
                        if (str_exists(result, cloned_cards)) {
                            continue;
                        }

                        // no more joker to replace
                        var cards_to_add = try allocator.alloc(u8, cloned_cards.len);
                        std.mem.copy(u8, cards_to_add, cloned_cards);

                        try result.append(cards_to_add);
                    } else {
                        //std.log.info("recursing on {s}\n", .{cloned_cards});
                        var history_card = try allocator.alloc(u8, cloned_cards.len);
                        std.mem.copy(u8, history_card, cloned_cards);
                        try history.append(history_card);

                        if (! (str_exists(result, cloned_cards))) {
                            try Hand.find_possible_hands(allocator, cloned_cards, history, result);
                        }
                    }
                }
            }
        }
    }
};

pub fn hand_is_less_than(_: void, h1: Hand, h2: Hand) bool {
    std.log.info("calling hand_is_less_than, h1 {s} h2 {s}\n", .{ h1.line, h2.line });

    var v_left = Hand.base_value_s(h1.allocator, h1.top_hands.items[0]) catch unreachable;
    var v_right = Hand.base_value_s(h2.allocator, h2.top_hands.items[0]) catch unreachable;

    if (v_left < v_right) {
        return true;
    }

    if (v_left == v_right) {
        for (0..h1.cards.len) |i| {
            var value_h1 = Hand.card_value(h1.allocator, h1.cards[i]) catch unreachable;
            var value_h2 = Hand.card_value(h1.allocator, h2.cards[i]) catch unreachable;

            if (value_h1 < value_h2) {
                return true;
            } else if (value_h1 > value_h2) {
                return false;
            }
        }
    }

    return false;
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

    while (try in_stream.readUntilDelimiterOrEof(&linebuf, '\n')) |line| {
        var hand = try Hand.init(allocator, line);

        var possible_hands = std.ArrayList([]const u8).init(allocator);
        var history_find_possible_hands = std.ArrayList([]const u8).init(allocator);

        try Hand.find_possible_hands(allocator, hand.cards, &history_find_possible_hands, &possible_hands);

        // free the history
        for (history_find_possible_hands.items) |history| {
            allocator.free(history);
        }
        history_find_possible_hands.deinit();

        for (possible_hands.items) |possible_hand| {
            if (hand.top_hands.items.len == 0) {
                try hand.append_top_hand(possible_hand);
            } else if (hand.top_hands.items.len > 0 and try Hand.base_value_s(allocator, possible_hand) == try Hand.base_value_s(allocator, hand.top_hands.items[0])) {
                try hand.append_top_hand(possible_hand);
            } else if (hand.top_hands.items.len > 0 and try Hand.base_value_s(allocator, possible_hand) > try Hand.base_value_s(allocator, hand.top_hands.items[0])) {
                // need to reset the top_hands
                hand.reinit_top_hands();
                try hand.append_top_hand(possible_hand);
            }
        }

        if (hand.top_hands.items.len == 0) {
            try hand.append_top_hand(hand.cards);
        }

        // free the possible hands
        for (possible_hands.items) |possible_hand| {
            allocator.free(possible_hand);
        }
        possible_hands.deinit();

        try hands.append(hand);
    }

    // arraylist to fixed array
    var hands_slice = try hands.toOwnedSlice();
    defer allocator.free(hands_slice);

    std.log.info("sorting:\n", .{});
    std.sort.insertion(Hand, hands_slice, {}, hand_is_less_than);

    var total_winnings: usize = 0;

    for (hands_slice, 1..) |hand, rank| {
        hand.deinit();

        total_winnings += rank * hand.bet;
    }

    std.log.info("total_winnings = {d}\n", .{total_winnings});
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
    var hand = try Hand.init(allocator, "AAA21 100");
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

    hand = try Hand.init(allocator, "ADCB1 100");
    try std.testing.expectEqual(try hand.is_one_pair(), false);
    hand.deinit();
}

test "is_high_card" {
    var allocator = std.testing.allocator;
    var hand_1 = try Hand.init(allocator, "12345 100");
    defer hand_1.deinit();
    try std.testing.expectEqual(try hand_1.is_high_card(), true);
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

test "hand_is_less_than" {
    var allocator = std.testing.allocator;
    var hand_1 = try Hand.init(allocator, "KK677 100");
    defer hand_1.deinit();
    try hand_1.append_top_hand("KK677");

    var hand_2 = try Hand.init(allocator, "KTQQT 100");
    defer hand_2.deinit();
    try hand_2.append_top_hand("KTQQT");

    try std.testing.expectEqual(hand_is_less_than({}, hand_1, hand_2), false);
    try std.testing.expectEqual(hand_is_less_than({}, hand_2, hand_1), true);
}

test "card_value" {
    var allocator = std.testing.allocator;

    try std.testing.expectEqual(try Hand.card_value(allocator, 'J'), 0);
    try std.testing.expectEqual(try Hand.card_value(allocator, '2'), 1);
    try std.testing.expectEqual(try Hand.card_value(allocator, 'A'), 12);
}
