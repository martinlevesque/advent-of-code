def max_joltage(input_s: str) -> int:
    result = -1

    for i, cur_ch in enumerate(input_s):
        for ch_right in input_s[i + 1 :]:
            current = int(cur_ch + ch_right)

            if current > result:
                result = current

    return result


def main():
    try:
        with open("3.txt", "r") as f:
            file_content = f.read()

            result = 0

            for line in file_content.splitlines():
                print(f"line = {line} {len(line)}")

                cur_max = max_joltage(line)
                print(f"max = {cur_max}")
                result += cur_max

            print(f"Result: {result}")

    except Exception as e:
        print("failed!", e)


if __name__ == "__main__":
    main()
