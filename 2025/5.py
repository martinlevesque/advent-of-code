def is_fresh(ingredient_id: int, intervals: list) -> bool:
    for interval in intervals:
        if ingredient_id >= interval["from"] and ingredient_id <= interval["to"]:
            return True

    return False


def main():
    try:
        with open("5.txt", "r") as f:
            file_content = f.read()

            reached_separator = False
            intervals = []
            nb_fresh_ingredients = 0

            for line in file_content.splitlines():
                if line == "":
                    reached_separator = True
                    continue

                if not reached_separator:
                    parts = line.split("-")

                    from_interval = int(parts[0])
                    to_interval = int(parts[1])

                    intervals.append({"from": from_interval, "to": to_interval})
                else:
                    ingredient_id = int(line)

                    if is_fresh(ingredient_id, intervals):
                        nb_fresh_ingredients += 1

            print(f"result = {nb_fresh_ingredients}")

    except Exception as e:
        print("failed!", e)


if __name__ == "__main__":
    main()
