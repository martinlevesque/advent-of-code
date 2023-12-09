const std = @import("std");

pub const Card = struct {
    // example: Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
    original_line: []const u8,
    allocator: std.mem.Allocator,
    winning_numbers: std.ArrayList(i32),
    player_numbers: std.ArrayList(i32),
    id: usize,

    pub fn init(line: []const u8, allocator: std.mem.Allocator) !Card {
        // split by :
        var it = std.mem.split(u8, line, ":");

        var card_id_part = it.next();

        if (card_id_part == null) {
            return error.CardMissingCardId;
        }

        var trimmed_card_id = std.mem.trim(u8, card_id_part.?, "Card ");
        var card_id = try std.fmt.parseInt(usize, trimmed_card_id, 10);

        var card_line_part = it.next();

        if (card_line_part == null) {
            return error.CardMissingCardLine;
        }

        var it_winning_player_sep = std.mem.split(u8, card_line_part.?, "|");

        var winning_part = it_winning_player_sep.next();

        if (winning_part == null) {
            return error.CardMissingWinningPart;
        }

        var player_part = it_winning_player_sep.next();

        if (player_part == null) {
            return error.CardMissingPlayerPart;
        }

        var winning_numbers = try Card.read_numbers(winning_part.?, allocator);
        var player_numbers = try Card.read_numbers(player_part.?, allocator);

        return Card{
            .original_line = line,
            .allocator = allocator,
            .winning_numbers = winning_numbers,
            .player_numbers = player_numbers,
            .id = card_id,
        };
    }

    pub fn read_numbers(line: []const u8, allocator: std.mem.Allocator) !std.ArrayList(i32) {
        var numbers = std.ArrayList(i32).init(allocator);

        var it = std.mem.split(u8, line, " ");

        while (it.next()) |part| {
            var trimmed = std.mem.trim(u8, part, " ");

            if (trimmed.len == 0) {
                continue;
            }

            var number = try std.fmt.parseInt(i32, trimmed, 10);
            try numbers.append(number);
        }

        return numbers;
    }

    pub fn count_points(self: *Card) i32 {
        var result: i32 = 0;

        for (self.player_numbers.items) |player_number| {
            for (self.winning_numbers.items) |winning_number| {
                if (player_number == winning_number) {
                    if (result == 0) {
                        result = 1;
                    } else {
                        result *= 2;
                    }
                }
            }
        }

        return result;
    }

    pub fn nb_matchings(self: *const Card) usize {
        var result: usize = 0;

        for (self.player_numbers.items) |player_number| {
            for (self.winning_numbers.items) |winning_number| {
                if (player_number == winning_number) {
                    result += 1;
                }
            }
        }

        return result;
    }

    pub fn count_ending_scratchboards_for(card: Card, cards: std.ArrayList(Card)) usize {
        var result: usize = 1; // the card itself

        var total_matchings = card.nb_matchings();

        var i = card.id;

        while (i < card.id + total_matchings and i < cards.items.len) : (i += 1) {
            var current_card = cards.items[i];
            result += count_ending_scratchboards_for(current_card, cards);
        }

        return result;
    }

    pub fn count_ending_scratchboards(cards: std.ArrayList(Card)) usize {
        var result: usize = 0;

        for (cards.items) |card| {
            result += count_ending_scratchboards_for(card, cards);
        }

        return result;
    }

    pub fn deinit(self: *Card) void {
        self.winning_numbers.deinit();
        self.player_numbers.deinit();
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
    var result: i32 = 0;
    var cards = std.ArrayList(Card).init(allocator);
    defer cards.deinit();

    while (try in_stream.readUntilDelimiterOrEof(&linebuf, '\n')) |line| {
        std.log.info("line = {s}\n", .{line});
        var card = try Card.init(line, allocator);
        try cards.append(card);

        result += card.count_points();
    }

    std.log.info("part 1 result: {d}\n", .{result});
    std.log.info("part 2 result: {d}\n", .{Card.count_ending_scratchboards(cards)});

    for (cards.items) |*card| {
        card.deinit();
    }
}

test "read_numbers" {
    var allocator = std.testing.allocator;

    var result = try Card.read_numbers("1 2   3  44", allocator);
    defer result.deinit();

    try std.testing.expectEqual(result.items.len, 4);
    try std.testing.expectEqual(result.items[0], 1);
    try std.testing.expectEqual(result.items[1], 2);
    try std.testing.expectEqual(result.items[2], 3);
    try std.testing.expectEqual(result.items[3], 44);
}

test "Card init" {
    var allocator = std.testing.allocator;

    var result = try Card.init("Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53", allocator);
    defer result.deinit();

    try std.testing.expectEqual(result.winning_numbers.items.len, 5);
    try std.testing.expectEqual(result.winning_numbers.items[0], 41);
    try std.testing.expectEqual(result.winning_numbers.items[1], 48);
    try std.testing.expectEqual(result.winning_numbers.items[2], 83);
    try std.testing.expectEqual(result.winning_numbers.items[3], 86);
    try std.testing.expectEqual(result.winning_numbers.items[4], 17);

    try std.testing.expectEqual(result.player_numbers.items.len, 8);
    try std.testing.expectEqual(result.player_numbers.items[0], 83);
    try std.testing.expectEqual(result.player_numbers.items[1], 86);
    try std.testing.expectEqual(result.player_numbers.items[2], 6);
    try std.testing.expectEqual(result.player_numbers.items[3], 31);
    try std.testing.expectEqual(result.player_numbers.items[4], 17);
    try std.testing.expectEqual(result.player_numbers.items[5], 9);
    try std.testing.expectEqual(result.player_numbers.items[6], 48);
    try std.testing.expectEqual(result.player_numbers.items[7], 53);

    try std.testing.expectEqual(result.id, 1);
}

test "count_points" {
    var allocator = std.testing.allocator;

    var result = try Card.init("Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53", allocator);
    defer result.deinit();

    try std.testing.expectEqual(result.count_points(), 8);
}

test "part 1 sample" {
    var allocator = std.testing.allocator;

    var result_1 = try Card.init("Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53", allocator);
    defer result_1.deinit();

    try std.testing.expectEqual(result_1.nb_matchings(), 4);

    var result_2 = try Card.init("Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19", allocator);
    defer result_2.deinit();

    try std.testing.expectEqual(result_2.nb_matchings(), 2);

    var result_3 = try Card.init("Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1", allocator);
    defer result_3.deinit();

    try std.testing.expectEqual(result_3.nb_matchings(), 2);

    var result_4 = try Card.init("Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83", allocator);
    defer result_4.deinit();

    try std.testing.expectEqual(result_4.nb_matchings(), 1);

    var result_5 = try Card.init("Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36", allocator);
    defer result_5.deinit();

    var result_6 = try Card.init("Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11", allocator);
    defer result_6.deinit();

    var result: i32 = result_1.count_points() + result_2.count_points() + result_3.count_points() + result_4.count_points() + result_5.count_points() + result_6.count_points();

    try std.testing.expectEqual(result, 13);

    var cards = std.ArrayList(Card).init(allocator);
    defer cards.deinit();

    try cards.append(result_1);
    try cards.append(result_2);
    try cards.append(result_3);
    try cards.append(result_4);
    try cards.append(result_5);
    try cards.append(result_6);

    try std.testing.expectEqual(Card.count_ending_scratchboards(cards), 30);
}

test "count_ending_scratchboards_for" {
    var allocator = std.testing.allocator;

    var card_1 = try Card.init("Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53", allocator); // 4 matchings
    defer card_1.deinit();

    var card_2 = try Card.init("Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19", allocator); // 2 matchings
    defer card_2.deinit();

    var card_3 = try Card.init("Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1", allocator); // 2 matchings
    defer card_3.deinit();

    var cards = std.ArrayList(Card).init(allocator);
    defer cards.deinit();

    try cards.append(card_1);
    try cards.append(card_2);
    try cards.append(card_3);

    try std.testing.expectEqual(Card.count_ending_scratchboards_for(card_1, cards), 4);
}
