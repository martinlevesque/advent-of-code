# part 1
def is_invalid_part_1(number: int) -> bool:
    number_s = str(number)

    if len(number_s) % 2 != 0:
        return False

    mid = len(number_s) // 2

    part_1 = number_s[:mid]
    part_2 = number_s[mid:]

    return part_1 == part_2


# part 2
def is_invalid_part_2(number: int) -> bool:
    number_s = str(number)

    max_sequence_size = len(number_s) // 2

    for i in range(max_sequence_size):
        seq_size = i + 1
        cur_number_s = number_s[:seq_size]

        nb_occurences = number_s.count(cur_number_s)

        if nb_occurences * len(cur_number_s) == len(number_s):
            return True

    return False


def sum_invalid_ids(range_min: int, range_max: int) -> int:
    result = 0

    for current in range(range_min, range_max + 1):
        if is_invalid_part_2(current):
            result += current

    return result


def main():
    try:
        with open("2.txt", "r") as f:
            file_content = f.read()

            result = 0

            for line in file_content.splitlines():
                sequences = line.split(",")
                cleaned_sequences = [x.strip() for x in sequences if x.strip()]

                for sequence in cleaned_sequences:
                    first_part, second_part = sequence.split("-")
                    print(f"fp {first_part} sp {second_part}")

                    current_sum = sum_invalid_ids(int(first_part), int(second_part))
                    result += current_sum

            print(f"Result: {result}")

    except Exception as e:
        print("failed!", e)


if __name__ == "__main__":
    main()
