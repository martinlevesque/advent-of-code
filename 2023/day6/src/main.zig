const std = @import("std");

pub const Race = struct {
    time: u32,
    record_distance: u32,

    pub fn count_possible_wins(self: *const Race) u32 {
        var result: u32 = 0;

        for (0..self.time) |i| {
            const push_duration = i+1;

            var cur_result: u32 = 0;
            var cur_speed: u32 = 0;

            for (0..self.time) |j| {
                if (j+1 > push_duration) {
                    cur_result += cur_speed;
                } else {
                    cur_speed += 1;
                }
            }

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

    // sample:
    //try races.append(Race{ .time = 7, .record_distance = 9 });
    //try races.append(Race{ .time = 15, .record_distance = 40 });
    //try races.append(Race{ .time = 30, .record_distance = 200 });

    // part 1
    try races.append(Race{ .time = 40, .record_distance = 233 });
    try races.append(Race{ .time = 82, .record_distance = 1011 });
    try races.append(Race{ .time = 84, .record_distance = 1110 });
    try races.append(Race{ .time = 92, .record_distance = 1487 });

    var result: ?u32 = null;

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
