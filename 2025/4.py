import copy

ROLL_OF_PAPER = "@"


def build_solution(mat: list[str]) -> tuple[list[str], int]:
    result = copy.deepcopy(mat)
    nb_x = 0

    for i, line_content in enumerate(mat):
        for j, cur_char in enumerate(line_content):
            nb_adjacents = 0

            if cur_char != ROLL_OF_PAPER:
                continue

            # left
            if j > 0 and line_content[j - 1] == ROLL_OF_PAPER:
                nb_adjacents += 1

            # right
            if j < len(line_content) - 1 and line_content[j + 1] == ROLL_OF_PAPER:
                nb_adjacents += 1

            # top
            if i > 0 and mat[i - 1][j] == ROLL_OF_PAPER:
                nb_adjacents += 1

            # bottom
            if i < len(mat) - 1 and mat[i + 1][j] == ROLL_OF_PAPER:
                nb_adjacents += 1

            # top-left
            if i > 0 and j > 0 and mat[i - 1][j - 1] == ROLL_OF_PAPER:
                nb_adjacents += 1

            # top-right
            if (
                i > 0
                and j < len(line_content) - 1
                and mat[i - 1][j + 1] == ROLL_OF_PAPER
            ):
                nb_adjacents += 1

            # bottom-left
            if i < len(mat) - 1 and j > 0 and mat[i + 1][j - 1] == ROLL_OF_PAPER:
                nb_adjacents += 1

            # bottom-right
            if (
                i < len(mat) - 1
                and j < len(line_content) - 1
                and mat[i + 1][j + 1] == ROLL_OF_PAPER
            ):
                nb_adjacents += 1

            if nb_adjacents < 4:
                result[i] = result[i][:j] + "x" + result[i][j + 1 :]
                nb_x += 1

    return result, nb_x


def main():
    try:
        with open("4.txt", "r") as f:
            file_content = f.read()

            mat = []

            for line in file_content.splitlines():
                mat.append(line)

            res, nb_x = build_solution(mat)
            print(f"mat: {res}")
            print(f"nb x = {nb_x}")

    except Exception as e:
        print("failed!", e)


if __name__ == "__main__":
    main()
