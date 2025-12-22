from dataclasses import dataclass


def is_fresh(ingredient_id: int, intervals: list) -> bool:
    for interval in intervals:
        if ingredient_id >= interval["from"] and ingredient_id <= interval["to"]:
            return True

    return False


@dataclass(order=True, frozen=True)
class IngredientInterval:
    interval_from: int
    interval_to: int

    def intersect_with(self, other: "IngredientInterval") -> bool:
        return not (
            self.interval_to < other.interval_from
            or other.interval_to < self.interval_from
        )


def part_2_sum_fresh_ingredients(intervals: list) -> int:
    result = 0

    for interval in intervals:
        result += interval.interval_to - interval.interval_from + 1

    return result


def part_2_insert_interval(
    new_interval: IngredientInterval, intervals: list[IngredientInterval]
) -> list[IngredientInterval]:
    merged = []
    to_merge = new_interval

    for interval in sorted(intervals):
        if interval.intersect_with(to_merge):
            to_merge = IngredientInterval(
                min(to_merge.interval_from, interval.interval_from),
                max(to_merge.interval_to, interval.interval_to),
            )
        else:
            merged.append(interval)

    merged.append(to_merge)

    return sorted(merged)


def main():
    with open("5.txt", "r") as f:
        file_content = f.read()

        reached_separator = False
        intervals = []
        nb_fresh_ingredients = 0
        initial_intervals = []

        for line in file_content.splitlines():
            if line == "":
                reached_separator = True
                continue

            if not reached_separator:
                parts = line.split("-")

                from_interval = int(parts[0])
                to_interval = int(parts[1])
                initial_intervals.append(IngredientInterval(from_interval, to_interval))

                # part 1
                # else:
                # ingredient_id = int(line)

                # if is_fresh(ingredient_id, intervals):
                #    nb_fresh_ingredients += 1

        initial_intervals = sorted(initial_intervals)
        intervals = initial_intervals

        for interval in initial_intervals:
            intervals = part_2_insert_interval(interval, intervals)

        nb_fresh_ingredients = part_2_sum_fresh_ingredients(intervals)

        print(f"result = {nb_fresh_ingredients}")


if __name__ == "__main__":
    main()
