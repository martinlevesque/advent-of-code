const std = @import("std");

pub const Race = struct {
    time: u64,
    record_distance: u64,

    pub fn count_possible_wins(self: *const Race) u64 {
        var result: u64 = 0;

        for (0..self.time) |i| {
            const push_duration = i+1;

            var cur_speed: u64 = push_duration;
            var cur_result: u64 = cur_speed * (self.time - push_duration);

            if (cur_result > self.record_distance) {
                result += 1;
            }
        }
    
        return result;
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var races = std.ArrayList(Race).init(allocator);
    defer races.deinit();

    // sample part1:
    //try races.append(Race{ .time = 7, .record_distance = 9 });
    //try races.append(Race{ .time = 15, .record_distance = 40 });
    //try races.append(Race{ .time = 30, .record_distance = 200 });

    // part 1
    //try races.append(Race{ .time = 40, .record_distance = 233 });
    //try races.append(Race{ .time = 82, .record_distance = 1011 });
    //try races.append(Race{ .time = 84, .record_distance = 1110 });
    //try races.append(Race{ .time = 92, .record_distance = 1487 });

    // sample part 2
    //try races.append(Race{ .time = 71530, .record_distance = 940200 });

    // part 2
    try races.append(Race{ .time = 40828492, .record_distance = 233101111101487 });

    var result: ?u64 = null;

    for (races.items) |race| {
        var cur_result = race.count_possible_wins();
        std.log.info("race time {d} result {d}\n", .{race.time, cur_result});

        if (result == null) {
            result = cur_result;
        } else {
            result = result.? * cur_result;
        }
    }

    std.log.info("final result {d}\n", .{result.?});
}

test "count_possible_wins" {
    var race = Race { .time = 30, .record_distance = 200 };
    try std.testing.expectEqual(race.count_possible_wins(), 9);
}
