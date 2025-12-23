import math


def operate(numbers: list, operator: str) -> int:
    if operator == "+":
        return sum(numbers)
    elif operator == "*":
        return math.prod(numbers)
    else:
        raise Exception(f"invalid operator {operator}")


def main():
    with open("6.txt", "r") as f:
        file_content = f.read()

        matrix = []

        for line in file_content.splitlines():
            grid = [line.split() for line in line.strip().splitlines()]

            row = grid[0]
            matrix.append(row)

        first_row = matrix[0]
        nb_columns = len(first_row)
        result = 0

        for i_column in range(nb_columns):
            print(f"i column {i_column}")

            numbers = []
            operator = ""

            for row in matrix:
                current_item = row[i_column]

                if current_item.isdigit():
                    numbers.append(int(current_item))
                else:
                    operator = current_item

            print(f"numbers {numbers}")
            operate_numbers_result = operate(numbers, operator)
            result += operate_numbers_result
            print(f"operate numbers res {operate_numbers_result}")

        print(f"result = {result}")


if __name__ == "__main__":
    main()
