class Resolver:
    def __init__(self, initial: int):
        self.current = initial

    def next(self, line: str) -> int:
        side = line[0]
        rotation_count_s = line[1:]
        rotation_count = int(rotation_count_s)
        rotation_remaining = rotation_count
        nb_zeros = 0

        if side == "L":
            while rotation_remaining > 0:
                if self.current - rotation_remaining < 0:
                    rotation_remaining -= self.current + 1

                    if self.current != 0:
                        nb_zeros += 1

                    self.current = 99
                else:
                    self.current -= rotation_remaining
                    rotation_remaining = 0

                    if self.current == 0:
                        nb_zeros += 1

        elif side == "R":
            while rotation_remaining > 0:

                if self.current + rotation_remaining > 99:
                    moving_right_up_to_limit = 99 - self.current

                    self.current = 0
                    rotation_remaining -= moving_right_up_to_limit + 1

                    nb_zeros += 1
                else:
                    self.current += rotation_remaining
                    rotation_remaining = 0

                    if self.current == 0:
                        nb_zeros += 1

        return nb_zeros

def main():
    try:
        resolver = Resolver(50)
        result = 0

        with open("1.txt", "r") as f:
            file_content = f.read()

            for line in file_content.splitlines():
                nb_zeros = resolver.next(line)

                result += nb_zeros

        print("result =", result)

    except Exception as e:
        print("failed!", e)


if __name__ == "__main__":
    main()
