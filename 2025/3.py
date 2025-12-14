from itertools import combinations


def max_joltage_part_1(input_s: str) -> int:
    result = -1

    for i, cur_ch in enumerate(input_s):
        for ch_right in input_s[i + 1 :]:
            current = int(cur_ch + ch_right)

            if current > result:
                result = current

    return result


def max_joltage_part_2(input_s: str) -> int:
    result = ""
    nb_digits_to_have = 12
    nb_to_remove = len(input_s) - nb_digits_to_have

    for cur_ch in input_s:
        while result and nb_to_remove > 0 and result[-1] < cur_ch:
            result = result[:-1]
            nb_to_remove -= 1

        result += cur_ch

    if nb_to_remove > 0:
        result = result[:-nb_to_remove]

    return int(result)


def main():
    try:
        with open("3.txt", "r") as f:
            file_content = f.read()

            result = 0

            for line in file_content.splitlines():
                print("=============================")
                print(f"line = {line} {len(line)}")

                cur_max = max_joltage_part_2(line)
                print(f"max = {cur_max}")
                result += cur_max

            print(f"Result: {result}")

    except Exception as e:
        print("failed!", e)


if __name__ == "__main__":
    main()
